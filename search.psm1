# Bing search URLs
$search = "https://www.bing.com/?q="
$searchNext = ""
$searchPage2 = "&first=11&FORM=PERE"
$searchPage3 = "&first=21&FORM=PERE1"
$searchResults = @()


function Search(){
Param(
    [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$True)]
    [string]$searchTerm,
    [Parameter(Position=1,
      Mandatory=$True,
      ValueFromPipeline=$True)]
	[int]$numberSearchResultsRequested,
	[Parameter(Position=2,
	Mandatory=$False,
	ValueFromPipeline=$True)]
	[string]$searchNext
	)
			
	$numberResultsRequested = $numberSearchResultsRequested
	
	$moreResults = (Invoke-WebRequest $search$searchTerm$searchNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing"
	$moreResultsLength = $moreResults.Length

	Write-Host("1. Found $moreResultsLength results of $numberResultsRequested")


	$searchResultsUpdated = TailorNumberMoreResults $moreResults $numberResultsRequested
	$searchResultsUpdatedLength = $searchResultsUpdated.Length
	$numberResultsRequested -= $searchResultsUpdatedLength

	Write-Host("2. Search results updated to $searchResultsUpdatedLength results of $numberResultsRequested ")

	$searchResults = $searchResults + $searchResultsUpdated

	if (-not (TestEnoughResults $numberResultsRequested)){
		Write-Host("3. Need $numberResultsRequested more results")
		SearchContinue $searchTerm $numberResultsRequested
	}
	else {
		DisplayResults $searchResults
		Write-Host("***Search complete***")
	}
}


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
		Write-Host("!!!!!!!!!!!!!!!!searchNext: $searchNext")
		$searchNextOld = $searchNext
		$searchNextUpdated = ""
		[string]$searchNextUpdated = IncrementNextPageURL $searchNextOld		
		Write-Host("SearchNextUpdated is $searchNextUpdated, page above 3 from URL $searchNext")
		$searchNext = ""
		$searchNext = $searchNextUpdated
	}

	Search $searchTerm $numberSearchResultsRequested $searchNext
}


function IncrementNextPageURL(){
	    Param(
        [Parameter(Position=0,
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [string]$linkNext        
		)
	  
		Write-Host("`n`nINCREMENTING URL $linkNext")

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

		Write-Host("A. Front number done; linkNext: $linkNext")

		# Increment final number
		$linkNextSplit = $linkNext -Split "PERE"
		$linkNumbersBack = $linkNextSplit[-1]
		Write-Host("B. Last number (=-seperated): $linkNumbersBack")
		$linkNumbers = [int]($linkNextSplit[-1])
		$linkNumbers++
		$linkNumbers = $linkNumbers.ToString()

		$linkFinal = $linkNextSplit[0]
		$linkFinal += ("PERE" + $linkNumbers)
		
		$linkFinal.Replace(" ", "")  # NOT WORKING; SHOULD REMOVE ALL INSTANCES OF " " IN THE URL STRING          
		Write-Host("C. linkFinal: $linkFinal")		

		Write-Host("`n`nRETURNING $linkFinal")
}

# Checks whether enough results returned. If so, display to user, else send to get more
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
}


# Adjust numberMoreResults to match amount still required by user 
function TailorNumberMoreResults{
	Param(
		[Parameter(Position=0,
		Mandatory=$True,
		ValueFromPipeline=$True)]
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

function UpdateNumberResultsRequested(){
	Param(
		[Parameter(Position=0,
		Mandatory=$True,
		ValueFromPipeline=$True)]
		[int]$moreResultsLength,
		[Parameter(Position=1,
		Mandatory=$True,
		ValueFromPipeline=$True)]
		[int]$numberResultsRequested
	)

	Write-Host("$moreResultsLength results so far of $numberResultsRequested")

	$numberResultsRequested -= $moreResultsLength

	Write-Host("$numberResultsRequested results still requested")
	return $numberResultsRequested
}