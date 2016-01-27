---
layout: post
title:  "Debugging Microsoft assemblies? Disable strong signing first"
date:   2016-01-22 23:07:40
tags: [strong-name-sign]
---

#### Woohoo, lets debug open source projects with strong signed assemblies
While experimenting with [Microsoft AspNet WebHooks preview](http://blogs.msdn.com/b/webdev/archive/2015/09/04/introducing-microsoft-asp-net-webhooks-preview.aspx) I noticed I'd like to make some changes to the existing code. Lets fork the [GitHub repo](https://github.com/aspnet/WebHooks) and try to build the solution. 
Building solutions from external sources is always ....  Oh awesome, building works without any hassle!
One thing I noticed though; the tests didn't run.

But nevermind, I just want to play around with the code a bit so lets worry about the tests later. After making my changes and trying to debug I encountered this error:
<p style="max-width:600px; margin: 0px auto;">
	<img src="/assets/strong-signed/strong-sign-error.png" alt="Strong sign error" style="border: 1px solid #E8E8E8;">	
</p>

<pre>
	Could not load file or assembly 'Microsoft.AspNet.WebHooks.Common' or one of its dependencies. 
	Strong name signature could not be verified.
	The assembly may have been tampered with, or it was delay signed but not fully signed with the correct private key. 
	(Exception from HRESULT: 0x80131045)
</pre>

That sucks, after reading about delay signing and OSS I thought I would be able to debug these projects. Fortunately it was not too hard to find [a solution](http://stackoverflow.com/questions/12100006/sgen-error-could-not-load-file-or-assembly-exception-from-hresult-0x801314#13009177).
First, find the public key token (for example on the error page)

<p style="max-width:600px; margin: 0px auto;">
	<img src="/assets/strong-signed/public-key-token.png" alt="Public key token" style="border: 1px solid #E8E8E8;">	
</p>

Then, start the VS developer console, or try to find sn.exe (Microsoft (R) .NET Framework Strong Name Utility).
With this tool we can register assemblies we want to skip the strong name check for. This is obviously not something you'd do on a live environment!
I used the -Vr param to register the assemblies I wanted to skip (all microsoft assemblies in this case):

<p style="max-width:600px; margin: 0px auto;">
	<img src="/assets/strong-signed/sn-tool.png" alt="SN tool" style="border: 1px solid #E8E8E8;">	
</p>

After registering the assemblies it is possible to debug. The test runner however didn't seem to be able to load the assemblies.

<pre>
	------ Discover test started ------
[xUnit.net 00:00:00.3261799] Skipping: Microsoft.AspNet.WebHooks.Custom.Mvc.Test (could not find dependent assembly 'Microsoft.AspNet.WebHooks.Custom.Mvc.Test, Version=0.0.0')
[xUnit.net 00:00:00.4738782] Skipping: Microsoft.AspNet.WebHooks.Custom.AzureStorage.Test (could not find dependent assembly 'Microsoft.AspNet.WebHooks.Custom.AzureStorage.Test, Version=0.0.0')
.....
[xUnit.net 00:00:00.2565380] Skipping: Microsoft.AspNet.WebHooks.Receivers.WordPress.Test (could not find dependent assembly 'Microsoft.AspNet.WebHooks.Receivers.WordPress.Test, Version=0.0.0')
[xUnit.net 00:00:00.2333480] Skipping: Microsoft.TestUtilities (could not find dependent assembly 'Microsoft.TestUtilities, Version=0.0.0')
========== Discover test finished: 0 found (0:00:06.0552803) ==========
</pre>
10 minutes and some ?$#@!$@!!?! later I found the solution: just restart Visual Studio :)

<p style="max-width:600px; margin: 0px auto;">
	<img src="/assets/strong-signed/it-pro-fix.jpg" alt="The universal fix" style="border: 1px solid #E8E8E8;">	
</p>