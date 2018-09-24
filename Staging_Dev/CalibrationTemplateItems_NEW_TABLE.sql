
--Creates new EntityDefaults and a new Table relating 2 EntityDefaults
--The "Definition" in [calibrationtemplateitems] is the new CT "capsule"
--The "TargetDefinition" is the MK2 CT template item itself

USE [perpetuumsa]
GO

--Create table to build new EntityDefault entries
CREATE TABLE #TEMP  
(targetdefinition int, 
definitionname varchar(100), 
quantity int,
attributeflags bigint,
categoryflags bigint,
options varchar(max),
note nvarchar(2048),
enabled bit,
volume float,
mass float,
hidden bit,
health float,
descriptiontoken nvarchar(100),
purchasable bit,
tiertype int,
tierlevel int)
INSERT INTO #TEMP 
SELECT definition, definitionname, 1, 2052, 1179, '', '',1, 0.1, 0.1, 0, 100, '', 1, 1, 2 FROM entitydefaults where definition in (SELECT definition from dynamiccalibrationtemplates)

--Set fields as necesary
UPDATE #TEMP SET
definitionname = definitionname+'_capsule',
quantity = 1,
attributeflags=2052,
categoryflags = 1179,
options = '',
note = 'MK2 CT Capsule!',
enabled= 1,
volume = 0.1,
mass = 0.1,
hidden = 0,
health = 100,
descriptiontoken ='calibration_program_desc',
purchasable = 1,
tiertype =1, 
tierlevel =  2;


--Insert the mk2 CT "capsule" definitions
INSERT INTO entitydefaults 
	([definitionname]
	,[quantity]
	,[attributeflags]
	,[categoryflags]
	,[options]
	,[note]
	,[enabled]
	,[volume]
	,[mass]
	,[hidden]
	,[health]
	,[descriptiontoken]
	,[purchasable]
	,[tiertype]
	,[tierlevel])
SELECT 
	[definitionname]
	,[quantity]
	,[attributeflags]
	,[categoryflags]
	,[options]
	,[note]
	,[enabled]
	,[volume]
	,[mass]
	,[hidden]
	,[health]
	,[descriptiontoken]
	,[purchasable]
	,[tiertype]
	,[tierlevel]
FROM #TEMP

--Create a new table in perpetuumsa DB to link the new Capsule definition to the target definition (the mk2 CT)
DROP TABLE IF EXISTS [perpetuumsa].[dbo].[calibrationtemplateitems];

CREATE TABLE [perpetuumsa].[dbo].[calibrationtemplateitems]
(definition int, targetdefinition int);

--Insert the relations
INSERT INTO [perpetuumsa].[dbo].[calibrationtemplateitems]
(definition, targetdefinition)
SELECT entitydefaults.definition, #TEMP.targetdefinition FROM #TEMP 
join entitydefaults on #TEMP.definitionname = entitydefaults.definitionname;


DROP TABLE IF EXISTS #TEMP

GO

