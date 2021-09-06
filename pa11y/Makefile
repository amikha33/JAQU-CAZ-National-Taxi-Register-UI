build:
	docker build -t pa11y-ci .

test:
	docker run -it -v /c/Users/echhu/projects/JAQU-CAZ-National-Taxi-Register-UI/pa11y/screenshots:/screenshots -e BASE_URL=https://dev-ntr-web.cleanairzone.defra.gov.uk pa11y-ci


bt:
	docker build -t pa11y-ci .
	docker run -it -v /c/Users/echhu/projects/JAQU-CAZ-National-Taxi-Register-UI/pa11y/screenshots:/screenshots -e BASE_URL=https://dev-ntr-web.cleanairzone.defra.gov.uk pa11y-ci
