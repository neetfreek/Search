<#***************************************************************
*  Return array of search result URLs to user from Bing search  *
****************************************************************#>


# Bing search URLs
$search = "https://www.bing.com/?q="
$searchNext = ""
$searchPage2 = "&first=11&FORM=PERE"
$searchPage3 = "&first=21&FORM=PERE1"
$searchResults = @()

# Progress information
$percentComplete = 0
$resultsRequested = 0


# Entry point
function Search(){
Param(
    [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$True)]
    [string]$searchTerm,
    [Parameter(Position=1,
      Mandatory=$True,
      ValueFromPipeline=$True)]
	[int]$numberResultsRequested,
	[Parameter(Position=2,
	Mandatory=$False,
	ValueFromPipeline=$True)]
	[string]$searchNext
	)
	
	$resultsRequested = $numberResultsRequested
	$searchTerm = $searchTerm.Replace(" ", "+")

	SearchLoop $searchTerm $numberResultsRequested $searchNext
}


# Get, add search result URLs to $searchResults
function SearchLoop{
	Param(
    [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$True)]
    [string]$searchTerm,
    [Parameter(Position=1,
      Mandatory=$True,
      ValueFromPipeline=$True)]
	[int]$numberResultsRequested,
	[Parameter(Position=2,
	Mandatory=$False,
	ValueFromPipeline=$True)]
	[string]$searchNext
	)
	
	UpdateProgress $numberResultsRequested

	$moreResults = (Invoke-WebRequest $search$searchTerm$searchNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing"
	
	$resultsUpdated = TailorNumberMoreResults $moreResults $numberResultsRequested
	if ($resultsUpdated.Length -gt 0){
		$searchResultsUpdated = TailorNumberMoreResults $moreResults $numberResultsRequested
	}
	else {
		DisplayResults $searchResults
		Write-Host("***Search complete***")
		break;
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
		  ValueFromPipeline=$True)]
		[string]$searchTerm,
		[Parameter(Position=1,
		  Mandatory=$True,
		  ValueFromPipeline=$True)]
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
          ValueFromPipeline=$True)]
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
		ValueFromPipeline=$True)]
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
		ValueFromPipeline=$True)]
		[array]$moreResults
	)
	$moreResults
	PrependURLNumbers $results
}


# Adjust numberMoreResults to match amount still required by user
function TailorNumberMoreResults{
	Param(
		[Parameter(Position=0,
		Mandatory=$True,
		ValueFromPipeline=$True)]
		[AllowEmptyCollection()]
		[array]$moreResults,
		[Parameter(Position=1,
		Mandatory=$True,
		ValueFromPipeline=$True)]
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