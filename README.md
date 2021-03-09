# OneDegree

![Deploy, Run Apex Tests, Delete Org](https://github.com/Salesforce-org-Impact-Labs/OneDegree/workflows/Deploy,%20Run%20Apex%20Tests,%20Delete%20Org/badge.svg)

One Degree Service Provider

## Release Links (Beta 6)
https://login.salesforce.com/packaging/installPackage.apexp?p0=04t3t000002XxwD

## Release Notes (13/09/2021)

1) Properties mapped to populate Housing and Employement section criteria's.
2) Eligibility of minimum age and maximum age set.
3) Batch job to execute long running zipcodes

## Testing

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
