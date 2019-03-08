


select m.n_number,
case type_aircraft
when '1' then 'Glider'
when '2' then 'Balloon'
when '3' then 'Blimp/Dirigible'
when '4' then 'Fixed wing single engine'
when '5' then 'Fixed wing multi engine'
when '6' then 'Rotorcraft'
when '7' then 'Weight-shift-control'
when '8' then 'Powered Parachute'
when '9' then 'Gyroplane'
when 'H' then 'Hybrid Lift'
when 'O' then 'Other'
end as aircraft_type,

case type_engine
when '0' then 'None'
when '1' then 'Reciprocating'
when '2' then 'Turbo-prop'
when '3' then 'Turbo-shaft'
when '4' then 'Turbo-jet'
when '5' then 'Turbo-fan'
when '6' then 'Ramjet'
when '7' then '2 Cycle'
when '8' then '4 Cycle'
when '9' then 'Unknown'
when '10' then 'Electric'
when '11' then 'Rotary'
end as engine_type,

 if(m.kit_mfr, m.kit_mfr, a.mfr) as manufacturer, if(m.kit_model, m.kit_model, a.model) as model, m.year_mfr,
case type_registrant 
when 1 then 'Individual'
when 2 then 'Partnership'
when 3 then 'Corporation'
when 4 then 'Co-Owned'
when 5 then 'Government'
when 8 then 'Non Citizen Corporation'
when 9 then 'Non Citizen Co-Owned'
else 'unknown' end as registrant_type,

case left(certification,1)
when 1 then 'Standard'
when 2 then 'Limited'
when 3 then 'Restricted'
when 4 then 'Experimental'
when 5 then 'Provisional'
when 6 then 'Multiple'
when 7 then 'Primary'
when 8 then 'Special Flight Permit'
when 9 then 'Light Sport'
else 'unknown'
end as airworthiness_class,



 m.name, m.city, m.state  
 
from master m left join aircraft a on m.mfr_mdl_code=a.code;



