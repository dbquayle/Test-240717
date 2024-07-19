#!/bin/sh

bow=./bow

said=10000000-0000-0000-0000-000000000001
daid=20000000-0000-0000-0000-000000000002

acctcfg="unused"
bankcfg="unused"
url="unused"

xids="44521ace-bba3-47b3-9657-731d1bf2b7c6 \
	 fdc33b4d-2d5a-4243-8ff1-099127e59283 \
	 5258d543-a151-4236-89d1-0166f2628ff5 \
	 e565c66d-b650-4628-a70c-723a75b77c22 \
	 656348f1-dbcb-46f2-8042-8a04bd60fc5e \
	 7d564a22-3247-4864-be93-71d3f7315ff2 \
	 da09ae9c-b762-493a-8eb9-7d3560136b77 \
	 dcd88b58-d023-436d-80ce-8af98e7d263b \
	 21b8886e-6030-49a7-8ab8-22231ab88251 \
	 ae21896e-05d8-433e-9016-778c73825029 \
	 97efdb22-771f-49ad-9255-675a353c5c66 \
	 c90a2277-f4b1-4723-a529-672fc3866703 \
	 7cec6f42-8b60-45b1-8dab-04f25d2abe89 \
	 9b710c0a-3363-49fc-90e3-c1386f0499ee \
	 ce29863b-d383-42ce-bb93-c9bdefead7be \
	 54e6769e-3ccc-4950-85e7-4f5919307ab5 \
	 520a69f9-30ef-48c1-8e61-9cf06e984ff6 \
	 6e9ff75c-87da-41f7-9bf7-d040c3084b03 \
	 a70294f8-4ec0-4e55-a514-127c14eac1a5 \
	 14837141-06fa-49a4-bd95-a1ca320d3c86 \
	 a884dfe7-0ace-4d31-ae58-0f55196728fb \
	 c89906d2-ddda-4912-9550-db8e11c677e6 \
	 1b4f1f72-b8b3-4fd3-bfac-bfa27a468511"

#xids="e74d81a3-c62a-451a-9a2e-6ab2f0b3475c"

for x in ${xids}; do
    echo ${bow} ${x} 100 ${said} ${url} ${bankcfg} ${acctcfg} ${daid} ${url} \
	 ${bankcfg} ${acctcfg};
    ${bow} ${x} 100 ${said} ${url} ${bankcfg} ${acctcfg} ${daid} ${url} \
	   ${bankcfg} ${acctcfg};    
done
	 
