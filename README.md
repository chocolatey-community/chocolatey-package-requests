# chocolatey-package-requests

Please submit your package requests as issues here

### Terminology

* RFP - Request for Package - this is for packages that do not exist
* RFM - Request for Maintainer(s) - this is for packages that do exist, but need new maintainers

## Etiquette Regarding Communication

If you are an open source user requesting support, please remember that most folks in the Chocolatey community are volunteers that have lives outside of open source and are not paid to ensure things work for you, so please be considerate of others' time when you are asking for things. Many of us have families that also need time as well and only have so much time to give on a daily basis. A little consideration and patience can go a long way.

### How To Create a Request

* Search and vote up an existing request or create a new request, using either "RFP - packagename" or "RFM - packagename";
* Using the template; explain a bit about the software if you can and possible hopes for what a package would look like;

### Before submitting a request for packager (RFP)

Search the [Chocolatey Community Repository](https://chocolatey.org/packages) to make sure the package doesn't already exist. Search using the program name and a hyphenated version of the program name; e.g. for Total Commander search for `totalcommander` and `total-commander`. You should also search for relevant tags such as `filemanager` or `file manager`.

### Before submitting a request for new maintainer(s) (RFM)

If you are the current maintainer of the package then create a new request using "RFM - packagename". If you are not the current maintainer then please make sure you have read the [Package Triage Process](https://chocolatey.org/docs/package-triage-process#package-is-outdated) and follow the guidelines there.

**NOTE**: Once a RFM request is accepted into the repository, any existing trusted status on chocolatey.org will be removed by the repository maintainers accepting the request.

### How To Create Packages for a Request

* Determine there is a package you can pick up.
* Comment on the issue that you would like to pick it up.
* The issue will get labelled as assigned, awaiting approval
* When the package gets approved by the moderation process, close the issue (or ask for it to be closed).

When you pick up a request for either a new package or a new maintainer, remember to keep the maintainers of this repository updated on the current status of the work being done.
A comment from the one picking up a request is expected to be done at the following stages of a request:

1. When you start working on the package, or get added as a new maintainer (issue will then be labeled as `Status: In Progress` and you will be assigned to the issue).
2. When the new package or updated version is pushed to chocolatey.org (issue will then be moved to `Status: Review`).
3. When the package is approved by a Chocolatey moderator (issue will then be closed and labeled with `Status: Published`).

A maintainer of the repository may at times add a comment on the issue asking for the status of the request when the above have not been followed.
When this happens, you will have 7 days to respond on the issue with the current status of the request.
If there is no response within these 7 days, the request will be opened up to other maintainers and marked with `Status: Available for Maintainer(s)`.

**Note**: If you are taking over maintenance for a package, you also need to be added to the list of maintainers. Use the contact admins link from the package page, point to the particular issue in this repository, and ask to be added.

### Package Request Status

The package requests repository uses Labels to show the current status of a request (this is heavily influented by user/maintainer feedback).
The main Labels are as follows with the corresponding meaning:

* [Status: Available for maintainer(s)](https://github.com/chocolatey/chocolatey-package-requests/labels/Status%3A%20Available%20For%20Maintainer%28s%29): As the name implies, this request is ready to be picked up by any maintainer that would like to work on creating/updating the request.
  * For new packages *(RFP)*, this means that the request have been accepted as a package that can be hosted on the community repository and the package do not exist.
  * For existing packages *(RFM)*, this means that the repository members have verified that the co-maintainer do not wish to continue working on the package, is unresponsive, and no outstanding questions are needed before handing the package over to a new maintainer.
* [Status: Triage](https://github.com/chocolatey/chocolatey-package-requests/labels/Status%3A%20Triage):
  * For new package *(RFP)*, this label is unlikely to be used, unless a member of the repository have any questions needed to be answered before a maintainer can pick the request up.
  * For existing package *(RFM)*, this label means that the members of the repository have been unable to verify that the [Package Triage](https://chocolatey.org/docs/package-triage-process#the-triage-process) process have been followed, or a repository member have a question before a new maintainer can be added.
* [Status: In Progress](https://github.com/chocolatey/chocolatey-package-requests/labels/Status%3A%20In%20Progress): A user have mentioned that they have started to work on the request, and/or a new maintainer have been added to the existing package.
* [Status: Review](https://github.com/chocolatey/chocolatey-package-requests/labels/Status%3A%20Review): A package for the current request have been submitted to chocolatey.org, and is currently awaiting a review from the chocolatey community moderators.
* [Status: Published](https://github.com/chocolatey/chocolatey-package-requests/labels/Status%3A%20Published): The package for the current request have been approved on the chocolatey community repository, and is now available for everyone to use.
* [Status: Blocked Upstream](https://github.com/chocolatey/chocolatey-package-requests/labels/Blocked%20Upstream): There are known issues that need to be resolved before a package can be created for the current request. (This can be everything from needing to embedd a package for a software that does not grant any distribution rights, download is blocked behind a login form, additional headers needed to be sent with the download request, and more...).
* [Status: Duplicate](https://github.com/chocolatey/chocolatey-package-requests/labels/Duplicate): The current request is a duplicate of a previous open request.
* [Status: High Virus Count](https://github.com/chocolatey/chocolatey-package-requests/labels/High%20Virus%20Count): The installer, or the package once it has been submitted, have been flagged with having a high virus count, by Virus Total. A high virus count is more than 15% of the scanners that were used by Virus Total on the package / installer flagging an issue.
* [Status: Not A Package Request / Can't Implement / Already Exists / Invalid](https://github.com/chocolatey/chocolatey-package-requests/labels/Not%20A%20Package%20Request%20%2F%20Can%27t%20Implement%20%2F%20Invalid): The issue raised is not a package or maintainer request, cannot be implemented as a package, already exists as a package or is otherwise invalid.