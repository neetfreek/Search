# Bing search URLs
$search = "https://www.bing.com/?q="
$searchNext = ""
$searchPage2 = "&first=11&FORM=PERE"
$searchPage3 = "&first=21&FORM=PERE1"
$searchResults = @()
# $numberResultsRequested

# Progress information
$percentComplete = 0
$resultsRequested = 0


<#
.Synopsis
This module returns as many Bing search result URLs as you like.
The companion module [navigate] allows you to access and view search result objects in your assigned search collection variable. For more, please see Get-Help navigate.

.Description
This module returns an array containing search result URLs for your search terms.
This module accepts your search term as a string parameter followed by an integer parameter representing the number of results you would like.
Up to as many results as can be found will be returned.
By assigning the return value to a variable, you can continue working with the links after the search is complete.

.Outputs
System.Array.Object[]
	Collection of search results

.Example
1. search dogs
This example returns 20 (default number) result URLs for the search term "dog" and displays the resulting URLs to the user.
.Example
1. $results = search "chocolate cake" 80
2. $results
3. navigate $results[3]
Step 1. returns 80 result URLs for the search term "chocolate cake" and assigns the returned value to the "$results" variable.
Step 2. displays the contents of the URL collection assigned to the "$results" variable
Step 3. displays the fourth result's body's innerText elements

.Notes
This script is still in development, and is a learning experience for myself. It may not be very efficient - or reliable - but I'm working on it :)

.LINK
http://neetfreek.net
#>
function Search(){
Param(
    [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$True)]
    [string]$searchTerm,
    [Parameter(Position=1,
      Mandatory=$False,
      ValueFromPipeline=$True)]
	[int]$numberResultsRequested
	)
		
	if ($numberResultsRequested -le 0){
		$numberResultsRequested = 20
	}

	$resultsRequested = $numberResultsRequested
	$searchTerm = $searchTerm.Replace(" ", "+")

	SearchLoop $searchTerm $numberResultsRequested
}


# Get, add search result URLs to $searchResults
function SearchLoop{
	Param(
    [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$False)]
    [string]$searchTerm,
    [Parameter(Position=1,
      Mandatory=$True,
      ValueFromPipeline=$False)]
	[int]$numberResultsRequested,
	[Parameter(Position=2,
	Mandatory=$False,
	ValueFromPipeline=$False)]
	[string]$searchNext
	)
	
	UpdateProgress $numberResultsRequested

	$moreResults = (Invoke-WebRequest $search$searchTerm$searchNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing"
	
	$resultsUpdated = TailorNumberMoreResults $moreResults $numberResultsRequested
	if ($resultsUpdated.Length -gt 0){
		$searchResultsUpdated = $resultsUpdated | Select-Object -Unique
		$searchResultsUpdated = TailorNumberMoreResults $resultsUpdated $numberResultsRequested
	}
	elseif ($searchResults.Length -eq 0 -or !$searchResults){
		Write-Host("***No results for $searchTerm found***`n`n")
		break
	}
	else {
		DisplayResults $searchResults
		Write-Host("***$searchTerm results:***`n`n")		
		break
	}
	$searchResultsUpdatedLength = $searchResultsUpdated.Length
	$numberResultsRequested -= $searchResultsUpdatedLength

	$searchResults = $searchResults + $searchResultsUpdated

	if (-not (TestEnoughResults $numberResultsRequested)){
		SearchContinue $searchTerm $numberResultsRequested
	}
	else {
		DisplayResults $searchResults
		Write-Host("***Search complete***")
	}
}


# Set appropriate search result page URL suffix
function SearchContinue{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchTerm,
		[Parameter(Position=1,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[int]$numberSearchResultsRequested
	)

	if (-not $searchNext){
		$searchNext = $searchPage2		
	} elseif ($searchNext -eq $searchPage2) {
		$searchNext = $searchPage3
	} else {
		$searchNextOld = $searchNext
		$searchNextUpdated = ""
		[string]$searchNextUpdated = IncrementNextPageURL $searchNextOld		
		$searchNext = ""
		$searchNext = $searchNextUpdated
	}

	SearchLoop $searchTerm $numberSearchResultsRequested $searchNext
}


# Increment search result page URL
function IncrementNextPageURL(){
	    Param(
        [Parameter(Position=0,
          Mandatory=$False,
          ValueFromPipeline=$False)]
        [string]$linkNext        
		)
	  
		# Increment first number
		$linkNextBeginning = "&first="

		$linkNumbers = (($linkNext -split "&")[1]) -replace '\D+(\d+)','$1'
		$linkNumbers.Substring(0, $linkNumbers.Length -1)
		$linkNumbersInt = [int]$linkNumbers.Substring(0, $linkNumbers.Length -1)

		$linkNumbersInt++
		$linkNumbers = $linkNumbersInt.ToString()
		$linkNumbers += "1"
		$linkNextBeginning += $linkNumbers
		$linkNextBeginning += ("&" + ($linkNext -Split "&")[-1])
		$linkNext = $linkNextBeginning

		# Increment final number
		$linkNextSplit = $linkNext -Split "PERE"
		$linkNumbers = [int]($linkNextSplit[-1])
		$linkNumbers++
		$linkNumbers = $linkNumbers.ToString()

		$linkFinal = $linkNextSplit[0]
		$linkFinal += ("PERE" + $linkNumbers)
		
		$linkFinal.Replace(" ", "")  
}


# Check whether enough results returned. If so, display to user, else send to get more
function TestEnoughResults{
	Param(
		[Parameter(Position=0,
		Mandatory=$False,
		ValueFromPipeline=$False)]
		[int]$numberResultsRequested
	)

	if ($numberResultsRequested -le 0){
		return $TRUE
	}
	else{
		return $FALSE
	}
}


# Display searh results to user
function DisplayResults{
	Param(
		[Parameter(Position=0,
		Mandatory=$True,
		ValueFromPipeline=$False)]
		[array]$results
	)
	PrependURLNumbers $results
	$results
}


# Adjust numberMoreResults to match amount still required by user
function TailorNumberMoreResults{
	Param(
		[Parameter(Position=0,
		Mandatory=$True,
		ValueFromPipeline=$False)]
		[AllowEmptyCollection()]
		[array]$moreResults,
		[Parameter(Position=1,
		Mandatory=$True,
		ValueFromPipeline=$False)]
		[int]$numberResultsRequested
	)

	if ($numberResultsRequested -le $moreResults.Length){  
		return $moreResults[0..($numberResultsRequested - 1)]
	}

	return $moreResults
}


# Display progress bar to user
function UpdateProgress{

	$percentComplete = ($searchResults.Length / $resultsRequested)  * 100

	Write-Progress -Activity "Getting Search Result Links..." -Status "$percentComplete Complete:" -PercentComplete $percentComplete 
}


# Prepend search result URLs with index number
function PrependURLNumbers(){
	Param(
	[Parameter(Position=0,
	Mandatory=$True,
	ValueFromPipeline=$False)]
	[AllowEmptyCollection()]
	[array]$searchResults
	)

	[string]$indexString = "0"
	[int]$indexInt = 0

	for($counter = 0; $counter -lt $searchResults.Length; $counter++){
		$indexInt = $counter
		$indexString = $indexInt.ToString()
		$indexString = "[$indexString] "
		$searchResults[$counter] = $indexString + $searchResults[$counter]
	}
}