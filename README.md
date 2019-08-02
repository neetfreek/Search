# PowerShell Search and Navigate Module
This module provides basic search engine and website navigation capabilities within Microsoft PowerShell - removing the need to use a browser.

<img src="/images/Example1.png" alt="example 1" align="left" width="432">
<img src="/images/Example2.png" alt="example 2" align="right" width="432">

## Setup
Clone this repository anywhere on your machine, launch PowerShell and use the `Install-Module` cmdlet to install both `search` and navigate:  
`PS C:\> Install-Module -Path C:\PathToDirectory\Search\search.psd1`

If you use this module often, it may be worth adding the above line to your profile.ps1 file. If you're unsure about profiles, please refer to the Microsoft documentation on profiles available at  
https://docs.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_profiles?view=powershell-6

## File Overview
- **search.psd1** The module manifest file - includes some basic information about the module.
- **search.ps1** Search logic - handles returning a collection of search term results using the Bing search engine.
-  **navigate.ps1** Navigation logic - handles displaying paragraph text and link content of websites.

## Use
### Basics
The most convenient way to use this module is to assign the return values (array collections) from search and navigate to variables. That way you can easily view and continue working with them. Below is an example.  
`PS C:\> $searchResults = search "neetfreek" 10` *(Assigns the first 10 (default 20) search result page URLs for "neetfreek" to the $searchResults variable)*  
`PS C:\> $searchResults` *(Display the 10 page URLs of the $searchResults variable)*  
`PS C:\> navigate $searchResults[0]` *(Displays the paragraph content of the first search result page's URL)*  
`PS C:\> $links = navigate $searchResults[0] -links` *(Assigns the link content of the first search result page's URL to the $links variable)*  
`PS C:\> $links` *(Displays the URL links content of the $links variable)*  
`PS C:\> navigate $links[2]` *(Displays the paragraph content of the third URL link in the $links variable)*

### Good to Know
All items in collection variables are zero-indexed. This module thus presents the contents of URL collections prepended with their zero-index indecies for ease-of-use.  
`navigate` accepts either an object in a collection returned from search (as per the `navigate $links[2]` example above) or a standard-format URL.  
`navigate` accepts an optional parameter, `-getContent`. This parameter accepts either `links` - which gets links - or `paras` - which gets paragraph content from the specified page. Other values are ignored.  

## More Information and Help
For more information on using this module as well as further examples, please refer to the `Get-Help` cmdlet for both `search` and `navigate`:  
`PS C:\> Get-Help search`  
`PS C:\> Get-Help navigate`
