require "date"
require "time"
require "net/http"
require "json"

require "./states/state"

class Florida < State
  DEPARTMENT = "Florida Department of Health"
  ACRONYM = "FDOH"

  def self.state_name
    "Florida"
  end

  def self.gallery_url
    "https://fdoh.maps.arcgis.com/home/gallery.html"
  end

  def self.counties_feature_url
    "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/ArcGIS/rest/services/Florida_COVID19_Cases/FeatureServer/0"
  end

  def self.cases_feature_url
    "https://services1.arcgis.com/CY1LXxl9zlJeBuRZ/ArcGIS/rest/services/Florida_COVID19_Case_Line_Data/FeatureServer/0"
  end

  def self.dashboard_url
    "https://experience.arcgis.com/experience/96dd742462124fa0b38ddedb9b25e429"
  end

  def self.case_keys
    {
      positives: {
        name: "Positives",
        description: "Includes both Florida residents and non-residents.",
        count_of_total_records: true,
        highlight: true
      },
      deaths: {
        name: "Deaths",
        positive_value: "Yes",
        highlight: true,
        source: "Died"
      },
      hospitalized_yes: {
        name: "Hospitalized - Yes",
        description: "Includes both Florida residents and non-residents unlike the FDOH dashboard which excludes non-residents in 'Hospitalizations'",
        positive_value: "YES",
        highlight: true,
        source: "Hospitalized"
      },
      hospitalized_no: {
        name: "Hospitalized - No",
        description: "Includes both Florida residents and non-residents unlike the FDOH dashboard which excludes non-residents in 'Hospitalizations'",
        positive_value: "NO",
        highlight: true,
        source: "Hospitalized"
      },
      emergency_visits_yes: {
        name: "Emergency Visits - Yes",
        positive_value: "YES",
        highlight: true,
        source: "EDvisit"
      },
      emergency_visits_no: {
        name: "Emergency Visits - No",
        positive_value: "NO",
        highlight: true,
        source: "EDvisit"
      },
      travel_related_yes: {
        name: "Travel Related - Yes",
        positive_value: "Yes",
        highlight: true,
        source: "Travel_related"
      },
      travel_related_no: {
        name: "Travel Related - No",
        positive_value: "No",
        highlight: true,
        source: "Travel_related"
      },
      residents: {
        name: "Florida Residents",
        positive_value: "FL resident",
        highlight: true,
        source: "Jurisdiction"
      },
      non_residents: {
        name: "Non-Florida Residents",
        positive_value: "Non-FL resident",
        highlight: true,
        source: "Jurisdiction"
      },
      not_diagnosed_in_florida: {
        name: "Not diagnosed/isolated in Florida",
        positive_value: "Not diagnosed/isolated in FL",
        highlight: true,
        source: "Jurisdiction"
      },
      contact_yes: {
        name: "Contact with COVID-19 positive - Yes",
        positive_value: "YES",
        highlight: true,
        source: "Contact"
      },
      contact_no: {
        name: "Contact with COVID-19 positive - No",
        positive_value: "NO",
        highlight: true,
        source: "Contact"
      },
      female: {
        name: "Female",
        positive_value: "Female",
        highlight: true,
        source: "Gender"
      },
      male: {
        name: "Male",
        positive_value: "Male",
        highlight: true,
        source: "Gender"
      },
      unknown_gender: {
        name: "Unknown Gender",
        positive_value: "Unknown",
        highlight: true,
        source: "Gender"
      }
    }
  end

  def self.county_keys
    {
      age_0_to_4: {
        name: "PUIs - Age - 0 to 4",
        highlight: false,
        source: "Age_0_4"
      },
      age_5_to_14: {
        name: "PUIs - Age - 5 to 14",
        highlight: false,
        source: "Age_5_14"
      },
      age_15_to_24: {
        name: "PUIs - Age - 15 to 24",
        highlight: false,
        source: "Age_15_24"
      },
      age_25_to_34: {
        name: "PUIs - Age - 25 to 34",
        highlight: false,
        source: "Age_25_34"
      },
      age_35_to_44: {
        name: "PUIs - Age - 35 to 44",
        highlight: false,
        source: "Age_35_44"
      },
      age_45_to_54: {
        name: "PUIs - Age - 45 to 54",
        highlight: false,
        source: "Age_45_54"
      },
      age_55_to_64: {
        name: "PUIs - Age - 55 to 64",
        highlight: false,
        source: "Age_55_64"
      },
      age_65_to_74: {
        name: "PUIs - Age - 65 to 74",
        highlight: false,
        source: "Age_65_74"
      },
      age_75_to_84: {
        name: "PUIs - Age - 75 to 84",
        highlight: false,
        source: "Age_75_84"
      },
      age_85_and_over: {
        name: "PUIs - Age - 85 and over",
        highlight: false,
        source: "Age_85plus"
      },
      age_unknown: {
        name: "PUIs - Age - Unknown",
        highlight: false,
        source: "Age_Unkn"
      },
      PUIs_residents: {
        name: "PUIs - Residents",
        highlight: false,
        source: "PUIFLRes"
      },
      PUIs_non_residents: {
        name: "PUIs - Non-residents",
        highlight: false,
        source: "PUINotFLRes"
      },
      PUIs_residents_out: {
        name: "PUIs - Residents Out of State",
        highlight: false,
        source: "PUIFLResOut"
      },
      PUIs_female: {
        name: "PUIs - Female",
        highlight: false,
        source: "PUIFemale"
      },
      PUIs_male: {
        name: "PUIs - Male",
        highlight: false,
        source: "PUIMale"
      },
      PUIs_sex_unknown: {
        name: "PUIs - Sex Unknown",
        highlight: false,
        source: "PUISexUnkn"
      },
      positive_age_0_to_4: {
        name: "Positives - Age - 0 to 4",
        highlight: false,
        source: "C_Age_0_4"
      },
      positive_age_5_to_14: {
        name: "Positives - Age - 5 to 14",
        highlight: false,
        source: "C_Age_5_14"
      },
      positive_age_15_to_24: {
        name: "Positives - Age - 15 to 24",
        highlight: false,
        source: "C_Age_15_24"
      },
      positive_age_25_to_34: {
        name: "Positives - Age - 25 to 34",
        highlight: false,
        source: "C_Age_25_34"
      },
      positive_age_35_to_44: {
        name: "Positives - Age - 35 to 44",
        highlight: false,
        source: "C_Age_35_44"
      },
      positive_age_45_to_54: {
        name: "Positives - Age - 45 to 54",
        highlight: false,
        source: "C_Age_45_54"
      },
      positive_age_55_to_64: {
        name: "Positives - Age - 55 to 64",
        highlight: false,
        source: "C_Age_55_64"
      },
      positive_age_65_to_74: {
        name: "Positives - Age - 65 to 74",
        highlight: false,
        source: "C_Age_65_74"
      },
      positive_age_75_to_84: {
        name: "Positives - Age - 75 to 84",
        highlight: false,
        source: "C_Age_75_84"
      },
      positive_age_85_and_over: {
        name: "Positives - Age - 85 and over",
        highlight: false,
        source: "C_Age_85plus"
      },
      positive_age_unknown: {
        name: "Positives - Age - Unknown",
        highlight: false,
        source: "C_Age_Unkn"
      },
      positive_age_average: {
        name: "Positives - Age Average",
        highlight: false,
        source: "C_AgeAvrg",
        total: true
      },
      positive_age_range: {
        name: "Positives - Age Range",
        highlight: false,
        source: "C_AgeRange",
        total: true
      },
      positive_all_residence_types: {
        name: "Positives - All Residence Types",
        highlight: false,
        source: "C_AllResTypes"
      },
      positive_men: {
        name: "Positives - Men",
        highlight: false,
        source: "C_Men"
      },
      positive_women: {
        name: "Positives - Women",
        highlight: false,
        source: "C_Women"
      },
      positive_travel: {
        name: "Positives - Travel-Related",
        highlight: false,
        source: "C_TravelYes"
      },
      positive_travel_no: {
        name: "Positives - Not Travel-Related",
        highlight: false,
        source: "C_TravelNo"
      },
      positive_travel_unknown: {
        name: "Positives - Unknown Travel",
        highlight: false,
        source: "C_TravelUnkn"
      },
      positive_no_emergency_admission: {
        name: "Positive Tests - No ER Admission",
        highlight: false,
        source: "C_ED_NO"
      },
      positive_emergency_admission: {
        name: "Positive Tests - ER Admission",
        highlight: false,
        source: "C_ED_Yes"
      },
      positive_unknown_emergency_admission: {
        name: "Positive Tests - Unknown ER Admission",
        highlight: false,
        source: "C_ED_NoData"
      },
      positives_race_white: {
        name: "Positives - Race - White",
        source: "C_RaceWhite"
      },
      positives_race_black: {
        name: "Positives - Race - Black",
        source: "C_RaceBlack"
      },
      positives_race_other: {
        name: "Positives - Race - Other",
        source: "C_RaceOther"
      },
      positives_race_unknown: {
        name: "Positives - Race - Unknown",
        source: "C_RaceUnknown"
      },
      positives_hispanic_yes: {
        name: "Positives - Hispanic - Yes",
        source: "C_HispanicYES"
      },
      positives_hispanic_no: {
        name: "Positives - Hispanic - No",
        source: "C_HispanicNO"
      },
      positives_hispanic_unknown: {
        name: "Positives - Hispanic - Unknown",
        source: "C_HispanicUnk"
      },
      inconclusive_total: {
        name: "Inconclusive Test Results - Total",
        highlight: false,
        source: "TInconc"
      },
      monitored_cumulative: {
        name: "Monitored - Cumulative Total",
        description: "Total number of cases that were at any point being monitored",
        highlight: false,
        source: "EverMon"
      },
      monitored_currently: {
        name: "Monitored - Current Total",
        description: "Total number of currently monitored persons by county",
        highlight: false,
        source: "MonNow"
      },
      cases_all: {
        name: "Cases - All",
        highlight: true,
        description: "The sum total of all positive cases, including Florida residents in Florida, Florida residents outside Florida, and non-Florida residents in Florida",
        source: "CasesAll"
      },
      pui_lab_yes: {
        name: "PUIs - Lab - Yes",
        description: "All persons tested with lab results on file, including negative, positive and inconclusive. Does NOT include those who are waiting to be tested or have submitted tests to labs for which results are still pending. ",
        highlight: true,
        source: "PUILab_Yes"
      },
      positives_total: {
        name: "Positive Tests - Total",
        description: "Florida and non-Florida residents, including residents tested outside of the Florida, and at private facilities.",
        highlight: true,
        source: "T_positive"
      },
      negatives_total: {
        name: "Negative Tests - Total",
        description: "Florida and non-Florida residents, including residents tested outside of the Florida, and at private facilities.",
        highlight: true,
        source: "T_negative"
      },
      pending_total: {
        name: "Pending Tests - Total",
        description: "Test administered but results pending.",
        highlight: true,
        source: "TPending"
      },
      cumulative_hospitalized: {
        name: "Positives - Hospitalized",
        description: "Hospitalization occurred at any time during illness. Not count of current hospitalizations.",
        highlight: true,
        source: "C_Hosp_Yes"
      },
      cumulative_hospitalized: {
        name: "Positives - Not Hospitalized",
        description: "Confirmed positive with no hospital admission noted, which could mean a confirmed person who has not been in the hospital, a person tested while not at a hospital, or any other combination of events that lead to the 'no' designation.",
        source: "C_Hosp_No"
      },
      cumulative_hospitalized_no_data: {
        name: "Positives - No Hospitalization Data",
        description: "Positives with no hospital admissions data",
        source: "C_Hosp_Nodata"
      },
      cumulative_hospitalized_residents: {
        name: "Positives - Hospitalization FL Residents",
        description: "Inpatient hospitalizations of confirmed-positive Florida residents only. ",
        source: "C_HospYes_Res"
      },
      cumulative_hospitalized_non_residents: {
        name: "Positives Hospitalization Non-FL Residents",
        description: "Inpatient hospitalizations of confirmed-positive non-Florida residents only. ",
        source: "C_HospYes_NonRes"
      },
      emergency_yes_resident: {
        name: "Emergency - Residents",
        description: "Emergency Dept Admissions for Florida Residents Only.",
        source: "C_EDYes_Res"
      },
      emergency_yes_non_resident: {
        name: "Emergency - Non-residents",
        description: "Emergency Dept Admissions for Non-Florida Residents.",
        source: "C_EDYes_NonRes"
      },
      positive_florida_residents: {
        name: "Positive - Florida Residents",
        description: "Positive Florida Residents in Florida",
        source: "C_FLRes"
      },
      positive_non_florida_residents: {
        name: "Positive - Non-Florida Residents",
        description: "Positive Non-Florida Residents in Florida",
        source: "C_NotFLRes"
      },
      positive_florida_residents_out: {
        name: "Positive - Florida Residents Outside Florida",
        description: "Positive Florida Residents Not in Florida",
        source: "C_FLResOut"
      },
      tests_negative_residents: {
        name: "Tests - Negative Residents",
        description: "Total number of negative Florida Residents tested.",
        source: "T_NegRes"
      },
      tests_negative_non_residents: {
        name: "Tests - Negative Non-Residents",
        description: "Total number of negative non-Florida residents in Florida tested.",
        source: "T_NegNotFLRes"
      },
      tests_pending_residents: {
        name: "Tests - Pending Residents",
        description: "Total number of Florida residents in Florida with results pending.",
        source: "T_PendRes"
      },
      tests_pending_non_residents: {
        name: "Tests - Pending Non-Residents",
        description: "Total number of non-Florida residents in Florida with results pending.",
        source: "T_PendNotRes"
      },
      tests_total: {
        name: "Tests - Total",
        description: "Total tests administered or pending for all PUIs, including positive, negative and pending results.",
        highlight: true,
        source: "T_total"
      },
      tests_pending: {
        name: "Tests - Pending",
        description: "Total Florida and Non-Florida residents tested with results pending",
        highlight: true,
        source: "T_pending"
      },
      PUIs_total: {
        name: "PUIs - Total",
        description: "Any person who has been or is waiting to be tested.",
        highlight: true,
        source: "PUIsTotal"
      },
      deaths_residents: {
        name: "Deaths - Residents",
        description: "May be out of date compared to the individual case death total which is updated more frequently.",
        highlight: true,
        source: "FLResDeaths"
      }
    }
  end

  def self.nomenclature
    <<~HTML
      <h2>Nomenclature</h2>
      <p>
        Referenced from <a href="https://fdoh.maps.arcgis.com/home/item.html?id=8d0de33f260d444c852a615dc7837c86">Florida COVID-19 Confirmed Cases</a>.
      </p>

      <dl>
        <dt>PUI</dt>
        <dd>
          Essentially, PUIs are any person who has been or is waiting
          to be tested. This includes: persons who are considered
          high-risk for COVID-19 due to recent travel, contact with a
          known case, exhibiting symptoms of COVID-19 as determined by
          a healthcare professional, or some combination thereof.
          PUI’s also include people who meet laboratory testing
          criteria based on symptoms and exposure, as well as
          confirmed cases with positive test results. PUIs include any
          person who is or was being tested, including those with
          negative and pending results.
        </dd>

        <dt>Monitored</dt>
        <dd>
          People the Florida Department of Health was notified of for
          possible monitoring because they are a contact of a case,
          recently traveled to an area with community spread, or were
          identified by the Centers for Disease Control and Prevention
          (CDC) as a part of an airline/ship contact investigation.
          Not all persons who were initially reported are still
          monitored, depending on their circumstances, negative test
          results, or continued period of no symptoms.
        </dd>

        <dt>Hospitalization</dt>
        <dd>
          Count of all laboratory confirmed cases in which an
          inpatient hospitalization occurred at any time during the
          course of illness. These people my no longer be hospitalized.
          This number does not represent the number of COVID-19 positive
          persons currently hospitalized. We do not have a figure for
          that information at this time.
        </dd>
      </dl>
    HTML
  end
end
