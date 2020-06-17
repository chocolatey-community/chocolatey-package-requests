class ErrorMessages {
    static [string]$invalidCommand = "I am sorry @{0}, but we did not recognize that command";
    static [string]$invalidCommandException = "We could not extract a valid command from the comment";
    static [string]$toolingMissing = "Some tooling is missing from the CI system, please make sure everything is installed (7zip and trid currently required).";
}

class PermissionMessages {
    static [string]$actionDenied = "I am sorry @{0}, but you do not seem to have permission to make this action!";
    static [string]$userAddDenied = "I am sorry @{0}, but you do not seem to have permission to add other users.";
    static [string]$userRemoveDenied = "I am sorry @{0}, but you do not seem to have permission to remove other users.";
    static [string]$issueUserAssigned = "@{0} a user have already been assigned to this issue. Validation will not run when a user is assigned.";
    static [string]$issueLabelAssigned = "@{0} this issue have been labeled. Validation will only run on unlabeled, labeled with {1} or with {2} issues.";
}

class StatusCheckMessages {
    static [string]$checkingExistingValidationComment = "Checking for comments already submitted by the package request validator...";
    static [string]$checkingForExistingIssues = "Checking for other issues matching {0}"
    static [string]$checkingUserMarkedChocolateySearched = "Checking if user have searched for packages on chocolatey.org";
    static [string]$checkingUserMarkedDownloadUrlPublic = "Checking if user have marked the download URL as being public and not bedind a paywall";
    static [string]$checkingUserProvidedDirectDownloadUrl = "Checking if the user have provided a direct download URL";
    static [string]$checkingUserProvidedSoftwareProjectUrl = "Checking if user have provided a URL to the software project";
    static [string]$checkingUserSearchedForOpenIssues = "Checking if the user have checked for already opened issues";
    static [string]$checkingValidMaintainerHeaderUsed = "Checking that the user have selected either Current Maintainer or that he/she don't want to become the maintainer.";
    static [string]$checkMarkedAsCurrentMaintainer = "Checking if the user have selected that they are the current maintainer";
    static [string]$checkMarkedAsFollowingTriageProcess = "Checking if user have marked that they have followed the Package Triage Process";
    static [string]$checkMarkedAsSearchedForIssues = "Checking if the user have marked that they have checked for existing issues";
    static [string]$checkPackageExistOnChocolatey = "Checking chocolatey.org for an existing package named {0}";
    static [string]$checkUserMarkedWithCorrectRFMTitle = "Checking if the user have marked the issue with RFM";
    static [string]$checkUserMarkedWithCorrectRFPTitle = "Checking if the user have marked the issue with RFP";
    static [string]$checkUserProvidedPackageSourceUrl = "Checking if the user have added the url to the package source";
    static [string]$checkUserProvidedPackageUrl = "Checking if the user have added the url to the package";
    static [string]$checkUserRemovedMaintainerContactedDate = "Checking if the user have removed the 'Date the maintainer was contacted' part";
    static [string]$checkUserRemovedMaintainerContactedMethod = "Checking if the user have removed the 'How the maintainer was contacted' part";
    static [string]$checkUserSuppliedMaintainerContactDate = "Checking if the user have added the date he/she contacted the current maintainer";
    static [string]$checkUserSuppliedMaintainerContactMethod = "Checking if the user have addded how he/she contacted the current maintainer";
    static [string]$creatingValidationComment = "Creating new comment with parsed validation data...";
    static [string]$existingValidationCommentFound = "Existing comment was found. Removing existing comment...";
    static [string]$fileDownloadCheck = "Downloading file from direct download URL for testing.";
    static [string]$fileDownloadedTest = "Testing downloaded file";
    static [string]$issueUsesRFPOrRFMTitle = "Checking if user have prefixed title withe RFP or RFM";
}

class StatusMessages {
    static [string]$bodyNotMatchingUpdating = "Body do not match with recommendation, updating...";
    static [string]$chocolateyUserConfirmed = "@{0} thank you for confirming your chocolatey username. You are now connected to the [{1}](https://chocolatey.org/profiles/{1}) chocolatey user.";
    static [string]$chocolateyUserConnected = "Chocolatey user [{0}](https://chocolatey.org/packages/{0}) has been connected to the github user @{1}";
    static [string]$chocolateyUserDisconnected = "Connected chocolatey user [{0}](https://chocolatey.org/profiles/{0}) have been removed.";
    static [string]$githubUserDisconnected = "Connected github user @{0} have been removed";
    static [string]$issueHaveBeenLabeled = "The issue have been labeled with a status label, thus no longer needing validation";
    static [string]$packageFoundOnChocolatey = "Package found, checking if package is listed.";
    static [string]$packageNotFoundForRFP = "Information did not find a package matching {0}. This is correct in this case for RFP requests.";
    static [string]$packageSourceUrlFound = "User did not provide a package source url, but a url was found. Updating...";
    static [string]$packageUrlFound = "Found empty Package URL in the body and a package that matches the title. Updating the body to reflect this package url";
    static [string]$requestingIssue = "Requesting issue #{0}...";
    static [string]$titleNotMatchingUpdating = "Title do not match with recommendation, updating...";
    static [string]$uncheckedRFMItemFound = "Found unchecked RFM item, but title contains/will be changed to RFM. Updating issue body to reflect this.";
    static [string]$uncheckedRFPItemFound = "Found unchecked RFP item, but title contains/will be changed to RFP. Updating issue body to reflect this.";
    static [string]$userAssignedToIssue = "A user have been assigned to the issue, no need to do any validation of this request.";
    static [string]$userNotMarkedRFMTitleCorrectly = "User have not marked that he/she have prefixed the issue title with RFM";
    static [string]$userNotMarkedRFPTitleCorrectly = "User have not marked that he/she have prefixed the issue title with RFP";
    static [string]$userNotProvidedPackageSourceUrl = "User seems to not have provided any URL to the package source (or one do not exist).";
    static [string]$userNotProvidedPackageUrl = "User seems to not have provided any URL to the package";
}

class StatusLabels {
    static [string]$statusLabelPrefix = "Status:"
    static [string]$availableRequest = "Status: Available For Maintainer(s)";
    static [string]$incompleteRequest = "Status: Incomplete Request";
    static [string]$triageRequest = "Status: Triage";
    static [string]$upstreamBlocked = "Blocked Upstream";
}

class ValidationMessages {
    static [string]$commentBodyDetection = "<!-- Package Request Validation -->";
    static [string]$commentBodyHeader = "## Package Request Validation`nWe have finished some basic validation of this request. The result of this validation can be found below:";

    # Success
    static [string]$availableSuccess = "Everything looks good in our book. This issue is now open to other maintainers.";
    static [string]$triageSuccess = "Everything looks good to our automated checks, it is now up to a human to validate the remaining steps. No action is required yet";

    # Errors detected for request header
    static [string]$errorsHeader = "### Request Issues to fix`n`n**We have found the following issues with this request. Please update the issue to reflect any necessary changes mentioned.**`n`n";

    # Notices detected for request header
    static [string]$noticesHeader = "### Request Notices`n`n**We found some issues we could not fully validate without user input, or by human review. Please make any necessary changes when appropriate.**`n`n";

    # Messages for any maintainers that would pick up this request header
    static [string]$maintainersHeader = "### New Maintainer Notices`n`nThis section details some parts of the request that any upcoming maintainer may need to take into consideration.`n`n";

    # Generic message about this check being in alpha

    static [string]$commentBodyFooter = "`n`n**Please note that this check is currently in alpha, and may not be able to detect everything correctly.`nHumans may also be able to detect other issues with this request.**";
    static [string]$invalidRequestType = "We could not parse the request type. Please ensure that the issue title starts with RFM or RFP and is in the following format: ``RF[MP] - package-id``";
    static [string]$packageExistsError = "Is this the package that you are requesting: https://chocolatey.org/packages/{0}? If this is not the package you are looking for, please update the issue title to something else that won't conflict with existing packages on chocolatey.org.";
    static [string]$packageExistsUnlistedError = "Is this the package you are requesting: https://chocolatey.org/packages/{0}. There is no listed versions, which means it do not show up during a search on chocolatey.org. If this is not the package you are looking for, please update the issue title to something else that won't conflict with existing packages on chocolatey.org.";
    static [string]$packageNotFoundError = "We could not find a package named {0}. Please verify that the issue title contains the id of the package, with the correct formatting.";

    # General validation messages
    static [string]$useCorrectTitleError = "Please update the title to start with RFP (Request For new Package) or RFM (Request For new Maintainer).";
    static [string]$userRequestedIssueWithEmptyBodyError = "We detected that an empty body have been used for this issue request, we have updated the issue with the default body for your type of request. Please update the issue by filling in all the necessary data the template asks.";

    # New package request validation messages

    static [string]$chocolateySearchNotMarkedError = "We could not detect that you have marked that you have tried to search for the package on chocolatey.org yet. If you have not tried to search for the package, please do so now; Otherwise update the issue.";
    static [string]$downloadUrlPublicMarkedError = "We could not detect that you have marked the download URL as public and it is not hidden behind a paywall. Please note that if the download is private, or if it is hidden behind a paywall, then a package can not be created by the community. The only way to have a package for this in these cases is to contact the developers of the software.";
    static [string]$fileValidationFailed = "We were unable to find a supported binary file in the download URL. Please make sure that the download URL is correct.";
    static [string]$fileValidationMaintainerNotice = "We were unable to directly download the provided software from the specified URL, additional work **may** be needed.";
    static [string]$githubSearchNotMarkedError = "We could not detect that you have already searched for [open issues](https://github.com/{0}/issues?q=is:issue+is:open+in:title+{1}) for this package. Please do so before opening new issues (it will lessen the burdon on those responsible for this repository).";
    static [string]$issuesFoundNotice = "We found the following open issues that may already match your request: {0}";
    static [string]$softwareDirectDownloadError = "We could not detect a direct download URL for the software, please add this to the *'Direct Download'* part of the template. If there is no direct download, thene there **may** not be possible to create a package for this request, and would require you to contact the software in this case to have a package.";
    static [string]$softwareProjectUrlError = "We could not detect that you have provided a URL to the software project site, please add this to the *'Software project URL:'* part of the template.";

    # General new maintainer request validation messages

    static [string]$bothMaintainerSectionsUsedError = "We found both a section for the current maintainer and the one section for those not being the current maintainer being used. If you are not the current maintainer of the package, please remove the section with the header ``### Current Maintainer``. If you are the current maintainer, please remove the section with the header ``### I DON'T Want To Become The Maintainer``. We have stopped remaining validation, and will continue the validation check when you have updated the issue.";
    static [string]$issueMissingRfmCheckboxError = "We could not detect a checkbox that says you have started the issue with RFM. Please add this item to the issue if it is missing.";
    static [string]$issueMissingRfpCheckboxError = "We could not detect a checkbox that says you have started the issue with RFP. Please add this item to the issue if it is missing.";
    static [string]$packageSourceUrlMissingNotice = "We could not detect that you have specified the url to the source of the package. If there is no package source available, then you can safely ignore this message. If there is a package source available, then please add this url to the *'Package source URL:'* part of the issue.";
    static [string]$packageUrlMissingError = "We could not detect that you have specified a URL to the package in this issue, and we were not able to locate any package matching the id in the issue title. Please update the issue title to match the package name, or add the URL to the *'Package URL:'* part of the issue.";

    # Current maintainer validation messages

    static [string]$currentMaintainerCheckboxMissingError = "We was able to verify that you are the maintainer of the package, however we could not detect this being mentioned in the issue. Please add the template checkbox for confirming that you are the current maintainer.";
    static [string]$currentMaintainerNotVerifiedUserIsKnownError = "We could not verify that you are a known maintainer of this package. We did find that you are a known user under a different chocolatey username. Please replace the ``Current Maintainer`` section with the template for ``I DON'T Want To Become The Maintainer`` section.";
    static [string]$currentMaintainerNotVerifiedUserIsUnknownError = "We could not verify that you are a known maintainer of this package. We also do not know which username your github account is associated with. Please add a comment with ``/confirm your-chocolatey-username`` to confirm and associate your github account with a chocolatey user, or replace the ``Current Maintainer`` section with the template for ``I DON'T Want To Become The Maintainer`` section.";

    # Not current maintainer validation messages

    static [string]$maintainerContactedDateMissingError = "We could not detect when you contacted the maintainer. Please add this information to the *'Date the maintainer was contacted:'* part of the template in the format of ``year-month-day`` (example with current date ``$(Get-Date -Format 'yyy-MM-dd')``.";
    static [string]$maintainerContactedMethodMissingError = "We could not detect how you contacted the maintainer. Please add this information to the `'How the maintainer was contacted'* part of the template.";
    static [string]$triageProcessNotFollowedError = "We could not detect that you have completed the Package Triage Process for this request. Please head over to the [Package Triage Process documentation](https://chocolatey.org/docs/package-triage-process#the-triage-process) and come back to this request when you have completed the process.";
}

class WarningMessages {
    static [string]$chocolateyUserConnected = "The chocolatey user [{0}](https://chocolatey.org/profiles/{0}) have already been connected to a github user.";
    static [string]$chocolateyUserMissing = "The user {0} do not exist on https://chocolatey.org. Make sure there is no typo in the username.";
    static [string]$downloadValidationFailed = "Downloading or file validation failed...";
    static [string]$exitingValidation = "Exiting validation.";
    static [string]$fileValidationFailed = "File validation failed. No supported binary type was found.";
    static [string]$githubUserConnected = "The github user {0} have already been connected to a chocolatey user.";
    static [string]$noDownloadUrlFound = "There was no direct download URL found to download and validate the binary file.";
    static [string]$templateMissingPackageUrlAndNoPackageMatchesTitle = "Could not detect a place in the issue body for the package url and no package was found to match the title.";
    static [string]$templateMissingRFMCheckbox = "We was unable to find a checkbox that reflects that the issue starts with RFM.";
    static [string]$templateMissingRFPCheckbox = "We was unable to find a checkbox that reflects that the issue starts with RFP.";
    static [string]$userIsKnowMaintainerMissingConfirmationPart = "User is the known maintainer of the package, but issue is missing the part that confirms this.";
    static [string]$userNotKnownMaintainerOfPackage = "User is not known as the maintainer of the package";
    static [string]$userNotRemovedMaintainerContactedDate = "User have forgotten to remove the 'Maintainer contacted date part', we'll try removing it";
    static [string]$userNotRemovedMaintainerContactMethod = "User have forgotten to remove the 'Maintainer contacted part', we'll try removing it";
    static [string]$userNotSelectedSearchingForIssues = "User have not checked that there is no open maintainer request for this issue request";
    static [string]$userNotSelectedTriageProcessFollowed = "User have not checked that he/she have followed the package triage process";
    static [string]$userNotSpecifiedContactDateOfMaintainer = "User did not provide the date the maintainer was contacted in a parsable format";
    static [string]$userNotSpecifiedContactMethodOfMaintainer = "User did not provide the method of contact on how the maintainer was contact.";
    static [string]$userNotSpecifiedCorrectRequestTitle = "User have not correctly used RFP or RFM in the issue title";
    static [string]$userRequestedNewMaintainer = "User mentioned this is a request for new maintainer, but no package was found";
    static [string]$userRequestedNewPackage = "User requested a new package to be created, but one was already found matching {0}";
    static [string]$userUsedBothCurrentMaintainerAndCommunityUserTemplate = "The user have used the sections for both the current maintainer, and the one for community users.";
    static [string]$userRequestedIssueWithEmptyBody = "The user have posted a new request with an empty body.";
}


function Write-WarningMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    if (Test-Path Env:\GITHUB_ACTIONS) {
        Write-Host "::warning ::$message"
    }
    else {
        Write-Warning $message
    }
}

function Write-ErrorMessage {
    param(
        [Parameter(Mandatory = $true)]
        [string]$message
    )

    if (Test-Path Env:\GITHUB_ACTIONS) {
        Write-Host "::error ::$message"
    }
    else {
        Write-Error $message
    }
}
