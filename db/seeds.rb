require 'open-uri'
require 'json'

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
'peter-thiel', 'dave-mcclure', 'kevin-rose', 'jack-dorsey', 'david-tisch', 'elon-musk', 'ron-conway', 'reid-hoffman', 'dave-morin'
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
# !!!!!!!!! Note we need to figure out how to do locations !!!!!!!! Separate Table?
# puts company_data["offices"]




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
      else
        c.dead_date = company_data["deadpooled_month"].to_s + "/" + company_data["deadpooled_day"].to_s + "/" + company_data["deadpooled_year"].to_s
      end

      # Logic written in if there is no founded month or day to make it 1/1 of the year it was founded
      if (company_data["founded_year"] == nil)
          c.founded_date = nil
        elsif (company_data["founded_month"] == nil)
          c.founded_date = "1/1/" + company_data["founded_year"].to_s
        else
          c.founded_date = company_data["founded_month"].to_s + "/" + company_data["founded_day"].to_s + "/" + company_data["founded_year"].to_s
      end


c.save

puts "There are #{Company.all.count} companies in the database"
puts "There are #{Industry.all.count} industries in the database"



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
        f.funding_date = round["funded_month"].to_s + "/" + round["funded_day"].to_s + "/" + round["funded_year"].to_s

        #### !!!!! FUNDING ROUND DATE IS NOT SAVING FOR MANY OF THEM - NEED TO FIGURE OUT

        f.save
        puts "There are #{Funding.all.count} funding rounds in the database"

        round["investments"].each do |investment|

          if investment["company"] != nil
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.funding_id = f.id
            i.investor_id = nil # use nil for now
            i.investor_perma= investment["company"]["permalink"]
            i.save
            puts "There are #{Investment.all.count} investments in the database"


          elsif investment["financial_org"] != nil
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.investor_id = nil # use nil for now
            i.funding_id = f.id
            i.investor_perma = investment["financial_org"]["permalink"]
            i.save
            puts "There are #{Investment.all.count} investments in the database"


          elsif investment["person"] != nil
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.investor_id = nil # use nil for now
            i.funding_id = f.id
            i.investor_perma = investment["person"]["permalink"]
            i.save
            puts "There are #{Investment.all.count} investments in the database"


          else
            # If there is a situation where there is a round but don't know who invested
            # Need to include funding_round_id when seeding
            i = Investment.new
            i.investor_id = nil
            i.funding_id = f.id
            i.investor_perma = "unattributed"
            i.save
          end

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
