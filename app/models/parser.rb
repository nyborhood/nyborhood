require 'json'
require 'rest_client'
require 'csv'

class Parser

FIELD_DATA = ["agency_name", "incident_address", "address_type", "borough", "city", "closed_date", "community_board", "complaint_type", "created_date", "cross_street_1", "cross_street_2", "descriptor", "due_date", "facility_type", "latitude", "longitude", "location_type", "needs_recoding", "park_borough", "park_facility_name", "resolution_action_updated_date", "school_address", "school_city", "school_code", "school_name", "school_not_found", "school_number", "school_phone_number", "school_region", "school_state", "school_zip", "street_name", "unique_key", "x_coordinate_state_plane_", "y_coordinate_state_plane_", "incident_zip"]

  def initialize(url)
    @url = url
  end

  def response
    JSON.parse(RestClient.get(@url))
  end

  def locate_building(street_address, zipcode)
    @building = Building.find_by_address(street_address, zipcode)
  end

  def parse_registered_buildings_txt
    buildings = File.read(@url)
    building_string = buildings.split(/[\r\n]+/)

    building_string.each do |building|
      new_bldg = building.split('|')
      if locate_building("#{new_bldg[2]} #{new_bldg[5]}", new_bldg[6])      
        @building.attributes = {:unique_building_id => new_bldg[0], :bin_number => new_bldg[9], :block_number => new_bldg[7], :community_board => new_bldg[10], :block_number => new_bldg[7], :lot_number => new_bldg[8], :management_program => new_bldg[12], :dob_building_class => new_bldg[13], :legal_stories => new_bldg[14], :legal_class_a => new_bldg[15], :legal_class_b => new_bldg[16], :registration_id => new_bldg[17], :lifecycle => new_bldg[18], :record_status => new_bldg[19]}
        @building.save
      else
        building_instance = Building.create(:unique_building_id => new_bldg[0],:borough => new_bldg[1], :address => "#{new_bldg[2]} #{new_bldg[5]}", :zip => new_bldg[6], :block_number => new_bldg[7], :lot_number => new_bldg[8], :bin_number => new_bldg[9], :community_board => new_bldg[10], :census_tract => new_bldg[11], :management_program => new_bldg[12], :dob_building_class => new_bldg[13], :legal_stories => new_bldg[14], :legal_class_a => new_bldg[15], :legal_class_b => new_bldg[16], :registration_id => new_bldg[17], :lifecycle => new_bldg[18], :record_status => new_bldg[19])
      end
    end
  end
  #at some point I need to remove the header row!

  def parse_complaints311_json
    response.each do |item|
      complaint = Complaint.new
      FIELD_DATA.each do |field|      
        complaint.send("#{field}=", item[field]) 
      end
      # complaint.save
    end
  end

  def all_buildings_csv
    CSV.foreach(@url) do |row|
      new_row = row.join(",")      
      borough, block, lot, cd, ct2010, cb2010, schooldist, council, zipcode, firecomp, policeprct, address, zonedist1, zonedist2, zonedist3, zonedist4, overlay1, overlay2, spdist1, spdist2, ltdheight, allzoning1, allzoning2, splitzone, bldgclass, landuse, easements, ownertype, ownername, lotarea, bldgarea, comarea, resarea, officearea, retailarea, garagearea, strgearea, factryarea, otherarea, areasource, numbldgs, numfloors, unitsres, unitstotal, lotfront, lotdepth, bldgfront, bldgdepth, ext, proxcode, irrlotcode, lottype, bsmtcode, assessland, assesstot, exemptland, exempttot, yearbuilt, builtcode, yearalter1, yearalter2, histdist, landmark, builtfar, residfar, commfar, facilfar, borocode, bbl, condono, tract2010, xcoord, ycoord, zonemap, zmcode, sanborn, taxmap, edesignum, appbbl, appdate, plutomapid, version = new_row.split(",")
      building = Building.create(:borough => borough.strip, :tax_block => block.strip, :tax_lot => lot.strip, :community_district => cd.strip, :census_tract => ct2010.strip, :census_block => cb2010.strip, :school_district => schooldist.strip, :city_council_district => council.strip, :zip => zipcode.strip, :fire_company => firecomp.strip, :police_precinct => policeprct.strip, :address => address.strip, :zoning_district1 => zonedist1.strip, :zoning_district2 => zonedist2.strip, :zoning_district3 => zonedist3.strip, :zoning_district4 => zonedist4.strip, :zoning_commercial_overlay1 => overlay1.strip, :zoning_commercial_overlay2 => overlay2.strip, :zoning_special_purpose_district1 => spdist1.strip, :zoning_special_purpose_district2 => spdist2.strip, :zoning_limited_height_district => ltdheight.strip, :zoning_all_components1 => allzoning1.strip, :zoning_all_components2 => allzoning2.strip, :split_zone => splitzone.strip, :building_class => bldgclass.strip, :land_use => landuse.strip, :num_of_easements => easements.strip, :type_of_ownership => ownertype.strip, :owner_name => ownername.strip, :lot_area => lotarea.strip, :floor_area_total => bldgarea.strip, :floor_area_commercial => comarea.strip, :floor_area_residential => resarea.strip, :floor_area_office => officearea.strip, :floor_area_retail => retailarea.strip, :floor_area_garage => garagearea.strip, :floor_area_storage => strgearea.strip, :floor_area_factory => factryarea.strip, :floor_area_other => otherarea.strip, :floor_area_area_souce => areasource.strip, :num_of_buildings => numbldgs.strip, :num_of_floors => numfloors.strip, :num_of_residential_units => unitsres.strip, :num_of_total_units => unitstotal.strip, :lot_frontage => lotfront.strip, :lot_depth => lotdepth.strip, :building_frontage => bldgfront.strip, :building_depth => bldgdepth.strip, :extension_code => ext.strip, :proximity_code => proxcode.strip, :irregular_lot_code => irrlotcode.strip, :lot_type => lottype.strip, :basement_type_grade => bsmtcode.strip, :assessed_land_value => assessland.strip, :assed_total_value => assesstot.strip, :exempt_land_value => exemptland.strip, :exempt_total_value => exempttot.strip, :year_built => yearbuilt.strip, :year_built_code => builtcode.strip, :year_altered1 => yearalter1.strip, :year_altered2 => yearalter2.strip, :historic_district_name => histdist.strip, :landmark_name => landmark.strip, :built_floor_area_ratio => builtfar.strip, :maximum_allowable_residential_far => residfar.strip, :maximum_allowable_commerical_far => commfar.strip, :maximum_allowable_facility_far => facilfar.strip, :borough_code => borocode.strip, :borough_tax_block_lot => bbl.strip, :condominium_number => condono.strip, :census_tract2 => tract2010.strip, :x_coordinate => xcoord.strip, :y_coordinate => ycoord.strip, :zoning_map_num => zonemap.strip, :zoning_map_code => zmcode.strip, :sanborn_map => sanborn.strip, :tax_map => taxmap.strip, :e_designation_num => edesignum.strip, :apportionment_bbl => appbbl.strip, :appotionment_date => appdate.strip, :pluto_map_id => plutomapid.strip, :version_num => version.strip)
    end
  end

  def parse_complaints311_csv
    CSV.foreach(@url) do |row|
      new_row = row.join(",")
      unique_key.strip, created_date, closed_date, agency, agency_name, complaint_type, descriptor, location_type, incident_zip, incident_address, street_name, cross_street_1, cross_street_2, intersection_street_1, intersection_street_2, address_type, city, landmark, facility_type, status, due_date, resolution_action_updated_date, community_board, borough, x_coordinate_state_plane, y_coordinate_state_plane, park_facility_name, park_borough, school_name, school_number, school_region, school_code, school_phone_number, school_address, school_city, school_state, school_zip, school_not_found, school_or_citywide_complaint, vehicle_type, taxi_company_borough, taxi_pick_up_location, bridge_highway_name, bridge_highway_direction, road_ramp, bridge_highway_segment, garage_lot_name, ferry_direction, ferry_terminal_name, latitude, longitude, location = new_row.split(",")

      complaint = Complaint.new(:agency_name => agency_name,  :incident_address => incident_address, :address_type => address_type, :borough => borough, :city => city, :closed_date => date_formatter(closed_date), :community_board => community_board, :complaint_type => complaint_type, :created_date => date_formatter(created_date), :cross_street_1 => cross_street_1, :cross_street_2 => cross_street_2, :descriptor => descriptor, :due_date => date_formatter(due_date), :facility_type => facility_type, :latitude => latitude, :longitude => longitude, :location_type => location_type, :park_borough => park_borough, :park_facility_name => park_facility_name, :resolution_action_updated_date => date_formatter(resolution_action_updated_date), :school_address => school_address, :school_city => school_city, :school_code => school_code, :school_name => school_name, :school_not_found => school_not_found, :school_number => school_number, :school_phone_number => school_phone_number, :school_region => school_region, :school_state => school_state, :school_zip => school_zip, :street_name => street_name, :unique_key => unique_key, :x_coordinate_state_plane_ => x_coordinate_state_plane, :y_coordinate_state_plane_ => y_coordinate_state_plane, :incident_zip => incident_zip)
      
      update_building_record(complaint) unless locate_building(incident_address, incident_zip).nil? 
      # complaint.save
    end
  end

  def smartystreets_csv
    CSV.foreach(@url) do |row|
      new_row = row.join(",")
      sequence, duplicate, deliverable, freeform, id, address, city, state, zip, firm_name, smartystreets_address, deliveryline2, urbanization, city, state, full_zip_code, ss_addresszip_code2, add_on_zipcode, pmb_unit, pmbnumber, processflag, flagreason, smartystreets_footnotes, ews, countyfips, countyname, dpvcode, dpvfootnotes, cmra, vacant, active, default_flag, lacs_ind, lacs_linkcode, lacs_linkind, delivery_point, checkdigit, delivery_point_barcode, carrier_route, record_type, ziptype, congressional_district, rdi, elotsequence, elot_sort, suite_link_match, time_zone, utc_offset, dst, latitude, longitude, precision = new_row.split(",")
      if id.to_i != 0
        building = Building.find(id)
        building.attributes = {ss_address: smartystreets_address, zip4: add_on_zipcode, ss_footnotes: smartystreets_footnotes, latitude: latitude, longitude: longitude, ss_lat_and_long_precision: precision, geo_checked: true}
        binding.pry
      end
    end
  end

  # def update_building_record(record)
  #   @building.attributes = {latitude: record.latitude, longitude: record.longitude}
  #   @building.save
  # end

  def date_formatter(date)
    DateTime.strptime(date, '%m/%d/%Y %I:%M:%S %p')
    rescue ArgumentError
      date
  end

end
#834233
#861904
# 101 1 AVENUE
# t = Parser.new("/Users/alishamcwilliams/Desktop/Development/Personal Projects/nyc_apartment_app/CSVs/buildings_update--2014-05-03/everything_without_A_footnote.csv")
# t = Parser.new("/Users/alishamcwilliams/Desktop/Development/Personal Projects/nyc_apartment_app/CSVs/Buildings20140301/Building20140228.txt")
# t = Parser.new("/Users/alishamcwilliams/Desktop/Development/Personal Projects/nyc_apartment_app/CSVs/nyc_pluto_13v2/BK.csv")
# Parser.new("https://data.cityofnewyork.us/api/views/erm2-nwe9/rows.json?accessType=DOWNLOAD")
# t = Parser.new("db/311_Service_Requests_from_2010_to_Present.csv")
