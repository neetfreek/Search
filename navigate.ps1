$page = ""

<#
.Synopsis
This module allows you to easily browse the contents - text in paragraphs or links - of web pages.
The companion module [search], allows you to find web pages online which can be used with this module. For more, please see Get-Help search.

.Description
This module returns an array containing your page view queries.
This module accepts both objects from search return value arrays as well as URLs as parameters and a second optional string parameter which
allows control for having either the paragraph (default) or link contents returned (using either "page" or "links").

.Outputs
System.Array.Object[]
	Collection of search results

.Example
1. navigate https://www.neetfreek.net
This example displays the paragraph contents of the URL (default behaviour).
.Example
1. navigate $results[0] -viewContent "links"
This example displays the link contents of a page (object in an array) returned by an earlier search module query

.Notes
This script is still in development, and is a learning experience for myself. It may not be very efficient - or reliable - but I'm working on it :)

.LINK
http://neetfreek.net
#>
function Navigate{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL,
		[Parameter(Position=1,
		Mandatory=$False,
		ValueFromPipeline=$False)]
	  [string]$viewContent
	)


	if (IsSearchObject $searchURL){
		$navigationURL = RemoveIndex $searchURL
		if (IsInternalLink $searchURL){
			$navigationURL = $page + $searchURL
		}
	}
	elseif (IsInternalLink $searchURL){
		$navigationURL = $page + $searchURL
	}
	else {
		$navigationURL = $searchURL
	}

	$page = (Invoke-WebRequest $navigationURL)

	switch ($viewContent){
		"" {DisplayBodyInnerText $page}
		"links" {DisplayLinks $page}
		"page" {DisplayBodyInnerText $page}
	}	
}


# Remove URL's index position in result collection for navigation
function RemoveIndex(){
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$searchURL
	)

	$splitURL = $searchURL -Split "]"
	return $splitURL[1]
}


# Display body of URL
function DisplayBodyInnerText{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[array]$page
	)

	Write-Host("***Paragraph content:`n`n***")		
	$pageP = foreach ($element in $page.ParsedHtml.body.getElementsByTagName("p"))
		{
			$element.innerText
		}

	foreach ($para in $pageP){
		$para + "`n"
	}

	return $pageP
}


# Display links of URL
function DisplayLinks{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[array]$page
	)

	Write-Host("***Links:***`n`n")		
	$links = $page.Links.href

	return $links
}


# Return true/false if provided URL for navigate() is/n't an object from search() array collection
function IsSearchObject{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$navigationURL
	)
	if ($navigationURL[0] -eq "["){
		return $true
	}

	return $false
}


# Return true/false if provided URL for navigate() is/n't an internal link beginning with "/"
function IsInternalLink{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[string]$navigationURL
	)
	if ($navigationURL[0] -eq "/"){
		return $true
	}

	return $false
}