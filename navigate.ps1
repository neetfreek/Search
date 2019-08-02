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
1. $pages = search neetfreek
2. $pages
3. navigate $pages[0]
4. $links = navigate $pages[0] -getContent "links"
5. $links
6. navigate $links[2]
This example (1.) returns and assigns 20 (default amount) search results in the $pages collection variable before (2.) displaying the contents of the collection. 
It then (3.) displays the paragraph content of the first page returned by the search before (4.) assigning all links of that page into the $links collection variable.
It then (5.) displays the contents of the collection, before finally (6.) displaying the paragraph content of the third link.

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
	  [string]$getContent
	)

	$impureURL= $false

	if (IsSearchObject $searchURL){
		$navigationURL = RemoveIndex $searchURL
		$impureURL = $true
	}
	if (!$impureURL) {
		$navigationURL = $searchURL
	}

	try {$page = (Invoke-WebRequest $navigationURL)}
	catch{
		Write-Host "Requested URL `"$navigationURL`" did not return any content."
		break
	}

	switch ($getContent){
		"links" {DisplayLinks $page $navigationURL}
		"paras" {DisplayBodyInnerText $page}
		default {DisplayBodyInnerText $page}
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
	$URLCleanded = $splitURL[1].Trim()
	return $URLCleanded
}


# Display body of URL
function DisplayBodyInnerText{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[array]$page
	)

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
		[array]$page,
		[Parameter(Position=1,
		Mandatory=$False,
		ValueFromPipeline=$False)]
	  [string]$navigationURL
	)

	$links = $page.Links.href
	$links = AppendDomainToInternalLinks $links $navigationURL
	$links = PrependURLNumbers $links	
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


# Prepend current page URL to links to sub-domains
function AppendDomainToInternalLinks{
	Param(
		[Parameter(Position=0,
		  Mandatory=$True,
		  ValueFromPipeline=$False)]
		[array]$URLCollection,
		[Parameter(Position=1,
		Mandatory=$True,
		ValueFromPipeline=$False)]
	  [string]$navigationURL
	)

	$linksUpdate = New-Object System.Collections.ArrayList
	$domainHost = ([System.Uri]$navigationURL).Host


	foreach ($URL in $URLCollection){
		if (IsInternalLink $URL){
			$URL = $domainHost + $URL
		}
		$linksUpdate += $URL
	}

	return $linksUpdate
}