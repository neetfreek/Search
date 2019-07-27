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
		Write-Host("4. Need $numberResultsRequested more results")
		Search $searchTerm $numberSearchResultsRequested $searchNext
	} elseif ($searchNext -eq $searchPage2) {
		Write-Host("Search page 3")		
	} else {
		Write-Host("Search page above 3")
	}	
}

# function SearchMore(){
#     Param(
#         [Parameter(Position=0,
#           Mandatory=$True,
#           ValueFromPipeline=$True)]
#         [string]$searchTerm,
#         [Parameter(Position=1,
#           Mandatory=$False,
#           ValueFromPipeline=$True)]
#         [int]$numberResultsRequested
# 	)

# 	$numberResultsRequested += 1

#     # Get URL for next set of search result URLs
#     $moreLinks = (Invoke-WebRequest $search$searchTerm).AllElements | Where-Object { $_.Class -eq "b_widePag sb_bp"} | Select-Object href
    
#     # Clean URL for use in Invoke-WebRequest
#     $linkNext = "&"
#     $linkNext += ($moreLinks -Split ";")[1] -Replace "amp*"
#     $linkNext += ($moreLinks -Split ";")[2] -replace "}"

# 	$moreResults = (Invoke-WebRequest $search$searchTerm$linkNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing"
# 	$moreResultsLength = $moreResults.Length
# 	# $moreResultsLength = $moreResults.Length
#     # if ($numberResultsRequested -le $moreResults.Length){  
#     #     $searchResults += $moreResults[0..$numberResultsRequested]
#     #     $searchResults
#     # }
#     # else {
#     #     $searchResults += $moreResults
#     #     $numberResultsRequested -= $moreResults.Length
#     #     $numberResultsRequested += 1
#     #     SearchRest $searchTerm $numberResultsRequested $searchResults $linkNext
# 	# }

# 	# $searchResults += $moreResults

# 	# if ($moreResultsLength -lt $numberResultsRequested){
#     #     $numberResultsRequested -= $moreResults.Length
#     #     SearchMore $searchTerm $numberResultsRequested $searchResults
# 	# }
# 	# $searchResults = AppendResultsToSearchResults $moreResults $numberResultsRequested

# 	UpdateNumberResultsRequested $moreResultsLength $numberResultsRequested
# }

# function SearchRest{
#     Param(
#         [Parameter(Position=0,
#           Mandatory=$True,
#           ValueFromPipeline=$True)]
#         [string]$searchTerm,
#         [Parameter(Position=1,
#           Mandatory=$False,
#           ValueFromPipeline=$True)]
#         [int]$numberResultsRequested,
#         [Parameter(Position=2,
#           Mandatory=$False,
#           ValueFromPipeline=$True)]
#         [array]$searchResults,
#         [Parameter(Position=3,
#           Mandatory=$False,
#           ValueFromPipeline=$True)]
#         [array]$linkNext        
#       )

#       $lengthDEBUG = $searchResults.Length

#       while ($numberResultsRequested -gt 0){
#           # Iterate 1st int in first parameter, iterate int at end of search URL or add one if none there

#             # Increment first number
#             $linkNextBeginning = "&first="

#             $linkNumbers = (($linkNext -split "&")[1]) -replace '\D+(\d+)','$1'
#             $linkNumbers.Substring(0, $linkNumbers.Length -1)
#             $linkNumbersInt = [int]$linkNumbers.Substring(0, $linkNumbers.Length -1)

#             $linkNumbersInt++
#             $linkNumbers = $linkNumbersInt.ToString()
#             $linkNumbers += "1"
#             $linkNextBeginning += $linkNumbers
#             $linkNextBeginning += ($linkNext -Split "&")[-1]
#             $linkNext = $linkNextBeginning

#             Write-Host("Link next updated: $linkNext")

#             # Increment final number or
#             if ($linkNext[-1][-1] -match "\d+"){       
#             Write-Host("End of URL a number")
#             $linkNext[-1][-1] ++          
#             # Concatenate number to end of link
#             } else {                
#             Write-Host("End of URL is not a number")                    
#                     $linkNext += "1"
#             }


#             $linkNext.Replace(" ", "")  # NOT WORKING; SHOULD REMOVE ALL INSTANCES OF " " IN THE URL STRING          

#             $moreResults = (Invoke-WebRequest $search$searchTerm$linkNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing" 

#             # If done
#             if (($numberResultsRequested -= $moreResults.Length) -le 0){
#                 $searchResults += $moreResults[0..$numberResultsRequested]
#             }
#             else {
#                 $searchResults += $moreResults
#                 $numberResultsRequested -= $moreResults.Length
#             }

#             $lengthDEBUG = $searchResults.Length
#             Write-Host("$lengthDEBUG resultes, find $numberResultsRequested more")
#             $searchResults
#       }
# }

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

	$searchResultsLength = $searchResults.Length
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