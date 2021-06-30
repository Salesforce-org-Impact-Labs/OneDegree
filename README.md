# OneDegree

![Deploy, Run Apex Tests, Delete Org](https://github.com/Salesforce-org-Impact-Labs/OneDegree/workflows/Deploy,%20Run%20Apex%20Tests,%20Delete%20Org/badge.svg)

One Degree Service Provider
## Managed Released v1.0
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t3t000002krPv

## Release Links (Beta 10)
# Installation Info

Sandbox & Scratch Orgs:
https://test.salesforce.com/packaging/installPackage.apexp?p0=04t3t000002krHSAAY

Production & Developer Edition Orgs:
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t3t000002krHSAAY

## Release Notes (06/29/2021)

1) Removed api keys of One Degree and Google Geo Coding service



## Testing
[![OneDegree Setup Video]](https://drive.google.com/file/d/1iCykc20FrrTjNRaOKnbIR5RMge4TlBSK/view?usp=sharing)
### Step 1
  Populate respective api keys in custom metadata<br/> "Geo Coding Auth Setting" and "One Degree Auth Setting"
### Step 2
  Create zipcodes and relevant search records for each zipcode in OD Zipcodes object
### Step 3
  Execute the geo coding service in developer console:<br/>
    svc_onedegree.GeoCodingServiceQueueable geo_svc = new svc_onedegree.GeoCodingServiceQueueable();
    ID jobID = System.enqueueJob(geo_svc);
### Step 4
  Once step 3 is complete, execute one degree batch job in developer console:<br/>
    Id batchId = Database.executeBatch(new svc_onedegree.OneDegreeServiceBatchable(), 1);

## Development

To work on this project in a scratch org:

1. [Set up CumulusCI](https://cumulusci.readthedocs.io/en/latest/tutorial.html)
2. Run `cci flow run dev_org --org dev` to deploy this project.
3. Run `cci org browser dev` to open the org in your browser.
