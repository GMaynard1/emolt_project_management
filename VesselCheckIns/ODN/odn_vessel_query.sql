SELECT
    boats.VESSEL_NAME,
    primary_contacts.FIRST_NAME,
    primary_contacts.LAST_NAME,
    primary_contacts.PHONE,
    primary_contacts.EMAIL,
    boats.PRIMARY_FISHERY,
    ports.PORT_NAME,
    ports.STATE_POSTAL,
    ports.LATITUDE,
    ports.LONGITUDE,
    gears.GEAR_CATEGORY
FROM
    VESSELS AS boats
INNER JOIN
    VESSEL_GEAR_TYPE AS gears ON boats.VESSEL_GEAR_TYPE_PK = gears.VESSEL_GEAR_TYPE_PK
INNER JOIN
    PORTS AS ports ON boats.PORT_PK = ports.PORT_PK
INNER JOIN
    CONTACTS AS contacts ON boats.TECHNICAL_CONTACT = contacts.CONTACT_PK
INNER JOIN CONTACTS AS primary_contacts ON boats.PRIMARY_CONTACT = primary_contacts.CONTACT_PK
WHERE
    (
		(contacts.LAST_NAME = 'CARROLL' AND contacts.FIRST_NAME = 'JACK')
		OR
		(contacts.LAST_NAME = 'VAN VRANKEN' AND contacts.FIRST_NAME = 'COOPER')
	)
    AND
    (boats.ACTIVE=1)
    ORDER BY VESSEL_NAME
    ;
