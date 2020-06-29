require "net/http"
require "json"
require "csv"
require "date"
require "time"

require "./states/state"
require "./states/florida"
require "redis"

Florida.get_county_data
county_testing_data = Florida.county_response_data

# testing_data_uri = URI "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/arcgis/rest/services/Florida_Testing/FeatureServer/0/query?where=1%3D1&objectIds=&time=&resultType=none&outFields=*&returnIdsOnly=false&returnUniqueIdsOnly=false&returnCountOnly=false&returnDistinctValues=false&cacheHint=false&orderByFields=&groupByFieldsForStatistics=&outStatistics=&having=&resultOffset=&resultRecordCount=&sqlFormat=none&f=pjson&token="
# testing_data_raw = Net::HTTP.get(testing_data_uri)
# testing_data_json = JSON.parse(testing_data_raw)

# {"OBJECTID_12_13"=>1,
#  "OBJECTID"=>1,
#  "DEPCODE"=>21,
#  "COUNTY"=>"041",
#  "COUNTYNAME"=>"GILCHRIST",
#  "DATESTAMP"=>"2000-05-16T00:00:00.000Z",
#  "ShapeSTAre"=>9908353355.45099,
#  "ShapeSTLen"=>487300.011359113,
#  "OBJECTID_1"=>21,
#  "County_1"=>"Gilchrist",
#  "State"=>"FL",
#  "OBJECTID_12"=>"1",
#  "DEPCODE_1"=>21,
#  "COUNTYN"=>"41",
#  "PUIsTotal"=>32,
#  "Age_0_4"=>3,
#  "Age_5_14"=>0,
#  "Age_15_24"=>4,
#  "Age_25_34"=>3,
#  "Age_35_44"=>7,
#  "Age_45_54"=>3,
#  "Age_55_64"=>3,
#  "Age_65_74"=>3,
#  "Age_75_84"=>4,
#  "Age_85plus"=>2,
#  "Age_Unkn"=>0,
#  "C_Age_0_4"=>0,
#  "C_Age_5_14"=>0,
#  "C_Age_15_24"=>0,
#  "C_Age_25_34"=>0,
#  "C_Age_35_44"=>0,
#  "C_Age_45_54"=>0,
#  "C_Age_55_64"=>0,
#  "C_Age_65_74"=>0,
#  "C_Age_75_84"=>0,
#  "C_Age_85plus"=>0,
#  "PUIAgeAvrg"=>"0",
#  "PUIAgeRange"=>"0 to 89",
#  "C_AgeAvrg"=>"46",
#  "C_AgeRange"=>"NA",
#  "C_AllResTypes"=>0,
#  "C_NonResDeaths"=>0,
#  "PUIFemale"=>17,
#  "PUIMale"=>15,
#  "PUISexUnkn"=>0,
#  "PUIFLRes"=>32,
#  "PUINotFLRes"=>0,
#  "PUIFLResOut"=>0,
#  "PUITravelNo"=>5,
#  "PUITravelUnkn"=>27,
#  "PUITravelYes"=>0,
#  "C_EDYes_Res"=>0,
#  "C_EDYes_NonRes"=>0,
#  "C_Hosp_No"=>0,
#  "C_Hosp_Nodata"=>0,
#  "C_Hosp_Yes"=>0,
#  "C_FLResDeaths"=>0,
#  "PUILab_Yes"=>32,
#  "TPositive"=>0,
#  "TNegative"=>32,
#  "TInconc"=>0,
#  "TPending"=>0,
#  "PUIContNo"=>1,
#  "PUIContUnkn"=>2,
#  "PUIContYes"=>0,
#  "CasesAll"=>0,
#  "C_Men"=>0,
#  "C_Women"=>0,
#  "C_FLRes"=>0,
#  "C_NotFLRes"=>0,
#  "C_FLResOut"=>0,
#  "T_NegRes"=>32,
#  "T_NegNotFLRes"=>0,
#  "T_total"=>32,
#  "T_negative"=>32,
#  "T_positive"=>0,
#  "Deaths"=>0,
#  "EverMon"=>0,
#  "MonNow"=>0,
#  "Shape__Area"=>0.0858306455302227,
#  "Shape__Length"=>1.42926667474908}

testing_keys = %w[
  cumulative_hospitalized_resident
  cumulative_hospitalized_non_resident
  cumulative_hospitalized
  PUIs_total
  PUIs_residents
  PUIs_non_residents
  PUIs_residents_out
  deaths_non_residents
  deaths_residents
  positive_emergency_admission_residents
  positive_emergency_admission_non_residents
  positives_total_quality
  positives_total
  negatives_total_quality
  negatives_total
  inconclusive_total
  pending_total
  pending_total_quality
  tests_total
  monitored_cumulative
  monitored_currently
]

testing_totals = testing_keys.each_with_object({}) do |key, store|
  store[key] = 0
end

county_testing_data[:features].each_with_object(testing_totals) do |test, store|
  a = test["attributes"]

  store["cumulative_hospitalized_resident"] += a["C_HospYes_Res"]
  store["cumulative_hospitalized_non_resident"] += a["C_HospYes_NonRes"]
  store["cumulative_hospitalized_non_resident"] += (a["C_HospYes_Res"] + a["C_HospYes_NonRes"])
  store["PUIs_total"] += a["PUIsTotal"]
  store["PUIs_residents"] += a["PUIFLRes"]
  store["PUIs_non_residents"] += a["PUINotFLRes"]
  store["PUIs_residents_out"] += a["PUIFLResOut"]
  store["deaths_non_residents"] += a["C_NonResDeaths"]
  store["deaths_residents"] += a["C_FLResDeaths"]
  store["positive_emergency_admission_residents"] += a["C_EDYes_Res"]
  store["positive_emergency_admission_non_residents"] += a["C_EDYes_NonRes"]
  store["positives_total_quality"] += a["TPositive"]
  # T_Positive can be nil, hence the `|| 0` to prevent coercion errors
  store["positives_total"] += a["T_Positive"] || 0
  store["negatives_total_quality"] += a["TNegative"]
  store["negatives_total"] += a["T_negative"]
  store["inconclusive_total"] += a["TInconc"]
  store["pending_total"] += a["T_pending"] || 0
  store["pending_total_quality"] += a["TPending"]
  store["tests_total"] += a["T_total"]
  store["monitored_cumulative"] += a["EverMon"]
  store["monitored_currently"] += a["MonNow"]
end

CSV.open("exports/florida_testing_#{Time.now.strftime("%Y-%m-%d_%Hh%Mm%Ss")}.csv", "wb") do |csv|
  csv << county_testing_data[:fields].map { _1["name"] }

  county_testing_data[:features].each do |record|
    csv << record["attributes"].values
  end
end

pp testing_totals
