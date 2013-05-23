require 'open-uri'
require 'json'
require 'date'

start_time = Time.now

base_url = "http://api.crunchbase.com/v/1/"
key = "atsvjzz7q9apzywd9ex3t67e"
api_key = "&api_key=#{key}"
cos = "companies.js?"
co = "company/"
fin = "financial-organization/"
person = "person/"


# Company Permalinks
companies =
[
'facebook', 'twitter', 'tumblr', 'amazon', '37signals', 'salesforce', 'stripe',  'asana', 'fab-com', 'google', 'zynga',
'path',  'tesla-motors', 'surveymonkey', 'linkedin', 'y-combinator', 'techstars'
]
# Individual Permalinks
individuals =
[
'peter-thiel', 'dave-mcclure', 'kevin-rose', 'jack-dorsey', 'david-tisch', 'elon-musk', 'ron-conway', 'reid-hoffman', 'dave-morin', 'mark-pincus'
]
# Venture Capital Permalinks
vcs =
[
'sv-angel', 'accel-partners', 'founders-fund', '500-startups',  'first-round-capital',
 'andreessen-horowitz', 'sequoia-capital'
]

Industry.destroy_all
Company.destroy_all
Individual.destroy_all
Financial.destroy_all
Investment.destroy_all
Funding.destroy_all
Location.destroy_all

# Have an issue because something like techstars y-combinator is classified as a company
# This probably shouldn't be a problem when we loop through each company and
# This makes me believe we may want to just put financial organizations and
# even individuals in the entity table and create a column called 'kind' that
# will allow us to distinguish which is which

# In terms of associating investments with companies with the investors, I think
# we will need to create all of the companies first, then create the funding rounds for each
# and then somehow try to link the two together there. We will run into issues if
# we try to create investments in companies that don't exist yet in our database

# --------------------------------------- Individual Seeding --------------------------------- #

individuals.each_index do |j|

    person_data = JSON.parse(open(base_url+person+individuals[j]+".js?"+api_key).read)

    i = Individual.new

    i.name = person_data["first_name"] + ' ' + person_data["last_name"]
    i.perma = person_data["permalink"]
    i.crunch_url = person_data["crunchbase_url"]
    i.home_url = person_data["homepage_url"]
    i.save
    end

puts "There are #{Individual.all.count} people in the database"

# --------------------------------------- Financial Org Seeding --------------------------------- #

vcs.each_index do |i|

    fin_data = JSON.parse(open(base_url+fin+vcs[i]+".js?"+api_key).read)

    f = Financial.new

    f.name = fin_data["name"]
    f.perma = fin_data["permalink"]
    f.crunch_url = fin_data["crunchbase_url"]
    f.home_url = fin_data["homepage_url"]

    if (fin_data["founded_year"] == nil)
      f.founded_date = nil
    elsif (fin_data["founded_month"] == nil)
      f.founded_date = "1/1/" + fin_data["founded_year"].to_s
    else
      f.founded_date = fin_data["founded_month"].to_s + "/" + fin_data["founded_day"].to_s + "/" + fin_data["founded_year"].to_s
    end
    f.save
# Note - Description doesn't come up for first round capital, accel or sv angel
# should we build in some logic to fill this in?

end

puts "There are #{Financial.all.count} financials in the database"

# -------------------------------- Company Seeding --------------------------------- #

  companies.each_index do |i|

      company_data = JSON.parse(open(base_url+co+companies[i]+".js?"+api_key).read)

      c = Company.new
      c.name = company_data["name"]
      c.perma = company_data["permalink"]
      # c.kind = "company"

      if Industry.find_by_name(company_data["category_code"]) == nil
        Industry.create(name: company_data["category_code"])
        c.industry_id = Industry.find_by_name(company_data["category_code"]).id
      else
        c.industry_id = Industry.find_by_name(company_data["category_code"]).id
      end

      c.crunch_url = company_data["crunchbase_url"]
      c.home_url = company_data["homepage_url"]
      # industry_sub = company_data["description"]


      # Logic in case the company is dead
      if company_data["deadpooled_year"] == nil
        c.dead_date = nil
      elsif company_data["deadpooled_month"] == nil
        c.dead_date = Date.new(company_data["deadpooled_year"])
      else
        c.dead_date = Date.new(company_data["deadpooled_year"].to_i, company_data["deadpooled_month"].to_i, company_data["deadpooled_day"].to_i)
      end

      # Write in logic if the company is acquired...

      # Logic written in if there is no founded month or day to make it 1/1 of the year it was founded
      if (company_data["founded_year"] == nil)
          c.founded_date = nil
      elsif (company_data["founded_month"] == nil)
          c.founded_date = Date.new( company_data["founded_year"]   )
      else
          c.founded_date = Date.new( company_data["founded_year"], company_data["founded_month"], company_data["founded_day"] )
      end
      # Note we are having the same problem with data like
      # Twitter, Stripe, Asana, etc.'s Founded Date coming up
      # as nil. On Crunchbase they are displayed as 06/08
      # and it is consistent for each of them

      # IMPORTANT - do we want t to save these date objects
      # Or something else


    end


c.save

      l = Location.new
      l.address1 = company_data['offices'][0]['address1']
      l.address2 = company_data['offices'][0]['address12']
      l.zipcode = company_data['offices'][0]['zip_code']
      l.city = company_data['offices'][0]['city']
      l.statecode = company_data['offices'][0]['state_code']
      l.countrycode = company_data['offices'][0]['country_code']
      l.latitude = company_data['offices'][0]['latitude']
      l.longitude = company_data['offices'][0]['longitude']
      l.description = company_data['offices'][0]['description']
      l.company_id = c.id
      l.save

puts "There are #{Company.all.count} companies in the database"
puts "There are #{Industry.all.count} industries in the database"
puts "There are #{Location.all.count} locations in the database"



      # -------------- Company Funding Rounds -------------- #

      company_data["funding_rounds"].each do |round|
        # Need to include entity_id when seeding
        f = Funding.new
        f.company_id = c.id
        f.company_perma = c.perma
        if round["round_code"] == "unattributed"
          f.funding_code = "venture round"
        else
          f.funding_code = round["round_code"]

        end
        f.funding_amount = round["raised_amount"]
        f.funding_currency = round["raised_currency_code"]

        if round["funded_year"] == nil
        f.funding_date = round["funded_month"].to_s + "/" + round["funded_day"].to_s + "/" + round["funded_year"].to_s

        # Funding_date is not saving for multiple instances of th

        f.save
        puts "There are #{Funding.all.count} funding rounds in the database"

        round["investments"].each do |investment|

          if investment["company"] != nil
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.funding_id = f.id
            i.company_perma = investment["company"]["permalink"]
            i.company_id = nil #Company.find_by_perma(i.company_perma).id
            i.save

          elsif investment["financial_org"] != nil
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.funding_id = f.id
            i.financial_perma = investment["financial_org"]["permalink"]
            i.financial_id = nil #Financial.find_by_perma(i.financial_perma).id
            i.save

          elsif investment["person"] != nil
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.funding_id = f.id
            i.individual_perma = investment["person"]["permalink"]
            i.individual_id = nil #Individual.find_by_perma(i.individual_perma).id
            i.save

          else
            # If there is a situation where there is a round but don't know who invested
            # Need to include funding_round_id when seeding
            # i = Investment.new
            # i.funding_id = f.id
            # i.investor_id = nil
            # i.company_perma = "unattributed"
            # i.save
          end
          puts "There are #{Investment.all.count} investments in the database"
        end


      end

      if company_data["ipo"] != nil

         f = Funding.new
         f.company_id = c.id
         f.company_perma = c.perma
         f.funding_code = 'ipo'
         f.funding_amount = company_data["ipo"]["valuation_amount"]
         f.funding_currency = company_data["ipo"]["valuation_currency_code"]
         f.funding_date= company_data["ipo"]["pub_month"].to_s + "/" + company_data["ipo"]["pub_day"].to_s + "/" + company_data["ipo"]["pub_year"].to_s
         f.save
      end

  end

end_time = Time.now

puts "It took #{end_time - start_time} seconds to run"
#20.73 seconds
