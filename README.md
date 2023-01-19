# OneDegree

![Deploy, Run Apex Tests, Delete Org](https://github.com/Salesforce-org-Impact-Labs/OneDegree/workflows/Deploy,%20Run%20Apex%20Tests,%20Delete%20Org/badge.svg)

This open source repo represents a way nonprofits leveraging [Service Match](https://appexchange.salesforce.com/listingDetail?listingId=a0N4V00000G62EOUAZ&preview=%222021-02-16T16%3A04%3A24.000Z%22&_ga=2.66955886.1104461436.1672937090-2046210617.1665412270&tab=e) can integrate a service provider to easily import life-changing social services that can then be referred to individuals in need. The code in this repo is a proof of concept and is intended to demonstrate a way to complete this and spark innovation for similar integrations with other service providers. Please read this readme in its entirety before installing it in your Sandbox.
##
[Service Match](https://www.salesforce.org/wp-content/uploads/2021/02/impact-labs-service-match-solution-brief-v2.pdf) is an open-source app designed for case managers who connect people experiencing homelessness to vital human services. With a single click, case managers can generate a personalized list of services based on client data that they’re already collecting. The proof of concept represented in this code reflects one way an organization could integrate the [One Degree API](https://www.1degree.org/) with Service Match to import available services and configure them to be leveraged by Service Match.
[Service Match](https://www.salesforce.org/blog/announcing-service-match-from-impact-labs/) was an output of [Salesforce.org Impact Labs](https://www.salesforce.org/impactlabs/). If you have questions or would like additional information or resources, please contact Stephanie Zeitz at szeitz@salesforce.com.




## Testing
[![OneDegree Setup Video]](https://drive.google.com/file/d/1iCykc20FrrTjNRaOKnbIR5RMge4TlBSK/view?usp=sharing)
### Step 1
  1. Populate 2 records in OD API Keys object, one for Google API key and another for One Degree API Key
  2. Verify respective URL endpoints in custom metadata<br/> "Geo Coding Auth Setting" and "One Degree Auth Setting"
### Step 2
  Create zipcodes and relevant search records for each zipcode in OD Zipcodes object.
  NOTE: In the related list of Zipcode, there is "Start Date" and "End Date", they are automatically populated by batch job. If you run another batch in less than 24 hours for the same zipcode for the items, it will skip the zipcodes, either you have to clear the Dates or add new items for the batch to pick up.
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
