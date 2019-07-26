$search = "https://www.bing.com/?q="

function Search(){
Param(
    [Parameter(Position=0,
      Mandatory=$True,
      ValueFromPipeline=$True)]
    [string]$searchTerm,
    [Parameter(Position=1,
      Mandatory=$False,
      ValueFromPipeline=$True)]
    [int]$numberResults
  )
    
    # Convert requested search results number to 0-based index
    $numberResults -= 1
    $searchResults = (Invoke-WebRequest $search$searchTerm).Links.href -match "http" -notmatch "microsoft" -notmatch "bing"

    if ($numberResults -le $searchResults.Length){
        $searchResults[0..$numberResults]
    }
    else {            
        $numberResults -= $searchResults.Length
        SearchMore $searchTerm $numberResults $searchResults
    }

    Write-Host("Search complete.");
}

function SearchMore(){
    Param(
        [Parameter(Position=0,
          Mandatory=$True,
          ValueFromPipeline=$True)]
        [string]$searchTerm,
        [Parameter(Position=1,
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [int]$numberResults,
        [Parameter(Position=2,
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [array]$searchResults
      )


    # Get next set of links (usually 20, seems like it's always in 10s)
    $moreLinks = (Invoke-WebRequest "https://www.bing.com/?q=$searchTerm").AllElements | Where-Object { $_.Class -eq "b_widePag sb_bp"} | Select-Object href
    
    # Clean link to next set of search result links
    $linkNextCleaning = ($moreLinks -Split ";")[1,2]
    $linkNext = "&"
    $linkNext += ($moreLinks -Split ";")[1] -Replace "amp*"
    $linkNext += ($moreLinks -Split ";")[2] -replace "}"

    $moreResults = (Invoke-WebRequest $search$searchTerm$linkNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing"

    if ($numberResults -le $moreResults.Length){  
        $searchResults += $moreResults[0..$numberResults]
        $searchResults
    }
    else {
        $searchResults += $moreResults
        $numberResults -= $moreResults.Length
        $numberResults += 1
        SearchRest $searchTerm $numberResults $searchResults $linkNext
    }
}

function SearchRest{
    Param(
        [Parameter(Position=0,
          Mandatory=$True,
          ValueFromPipeline=$True)]
        [string]$searchTerm,
        [Parameter(Position=1,
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [int]$numberResults,
        [Parameter(Position=2,
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [array]$searchResults,
        [Parameter(Position=3,
          Mandatory=$False,
          ValueFromPipeline=$True)]
        [array]$linkNext        
      )

      $lengthDEBUG = $searchResults.Length
      Write-Host("$lengthDEBUG resultes so far, find $numberResults more. Current linkNext is $linkNext")

      while ($numberResults -gt 0){
          # Iterate 1st int in first parameter, iterate int at end of search URL or add one if none there

            # Increment first number
            $linkNextBeginning = "&first="

            $linkNumbers = (($linkNext -split "&")[1]) -replace '\D+(\d+)','$1'
            $linkNumbers.Substring(0, $linkNumbers.Length -1)
            $linkNumbersInt = [int]$linkNumbers.Substring(0, $linkNumbers.Length -1)

            $linkNumbersInt++
            $linkNumbers = $linkNumbersInt.ToString()
            $linkNumbers += "1"
            $linkNextBeginning += $linkNumbers
            $linkNextBeginning += ($linkNext -Split "&")[-1]
            $linkNext = $linkNextBeginning

            Write-Host("Link next updated: $linkNext")

            # Increment final number or
            if ($linkNext[-1][-1] -match "\d+"){       
            Write-Host("End of URL a number")
            $linkNext[-1][-1] ++          
            # Concatenate number to end of link
            } else {                
            Write-Host("End of URL is not a number")                    
                    $linkNext += "1"
            }


            $linkNext.Replace(" ", "")  # NOT WORKING; SHOULD REMOVE ALL INSTANCES OF " " IN THE URL STRING          

            $moreResults = (Invoke-WebRequest $search$searchTerm$linkNext).Links.href -match "http" -notmatch "microsoft" -notmatch "bing" 

            # If done
            if (($numberResults -= $moreResults.Length) -le 0){
                $searchResults += $moreResults[0..$numberResults]
            }
            else {
                $searchResults += $moreResults
                $numberResults -= $moreResults.Length
            }

            $lengthDEBUG = $searchResults.Length
            Write-Host("$lengthDEBUG resultes, find $numberResults more")
            $searchResults
      }
}