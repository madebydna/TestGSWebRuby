def stuff(state)
  <<~USAGE
  use _#{state};
  drop procedure if exists schema_change;
  delimiter ';;'
  create procedure schema_change() begin

      /* delete columns if they exist */
      if exists (select * from information_schema.columns where table_schema = schema() and table_name = 'school' and column_name = 'canonical_url') then
          alter table school drop column canonical_url;
      end if;

      /* add columns */
      ALTER table school ADD canonical_url VARCHAR(500) NULL;

  end;;

  delimiter ';'
  call schema_change(); 
  drop procedure if exists schema_change; \n
  USAGE
end

f = File.new('test_script.txt', 'a')

States.abbreviation_hash.keys.each do |state|
  f.write(stuff(state))
end
f.close
