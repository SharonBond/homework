create or replace view region as select country_name, country_code, state_name, state_alpha, state_fips_code,  
case 
when state_alpha in ('DE', 'MD', 'VA', 'WV', 'KY', 'NC', 'SC', 'TN' , 'GA', 'FL', 'AL', 'MS', 'AR', 'LA' ) then 'South'
when state_alpha in ('ID',  'AZ', 'UT', 'NV', 'CA', 'OR', 'WA', 'AK', 'HI') then 'Pacific'
when state_alpha in ('MA', 'NH', 'VT', 'MA', 'RI', 'CT', 'NY', 'NJ', 'PA', 'ME') then 'Northeast'
when state_alpha in ('MT', 'ND', 'SD', 'WY',  'NE', 'KS' , 'CO',  'TX', 'OK', 'NM') then 'Plains'
when state_alpha in ('OH', 'MI', 'IN', 'WI', 'IL', 'MN', 'IA', 'MO') then 'Midwest'
else 'undefined' end as region
from location;

question 5
select sum(ccd.value) as total_value, ccd.unit_desc, pd.state_name 
from 
colony_collapse_disorder ccd
inner join period  pd
on ccd.survey_id = pd.survey_id
where cast(ccd.survey_id as text) like ('%20')
group by ccd.unit_desc, pd.state_name
order by 1 desc
limit 5

