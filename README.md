
This is a guide to help developers get up to speed with the development.

Prerequisites
--------------------

This project runs on iOS 6.0 and above devices, these step-by-step instructions are written for Xcode 5. If you are using a previous version of Xcode, you may want to update before starting.

Installation via Cocoapods
--------------------

Step 1: Download CocoaPods
---------------

> You could check out [Introduction to CocoaPods](http://www.raywenderlich.com/12139/introduction-to-cocoapods) instead of this step.

[CocoaPods](http://cocoapods.org) is the dependency manager for Objective-C projects. It has thousands of libraries and can help you scale your projects elegantly.

CocoaPods is distributed as a ruby gem, and is installed by running the following commands in Terminal.app:

    $ sudo gem install cocoapods
    $ pod setup

> Depending on your Ruby installation, you may not have to run as `sudo` to install the cocoapods gem.

Step 2: Clone the repository
---------------

Please clone the repo from remote to your local. You could use Github app to clone the repository. Please refer [Help from Github.com](https://help.github.com/articles/working-with-repositories#cloning).

Or you could run the followng command in the Terminal.

    $ cd PATH_TO_CLONE
    $ git clone https://github.com/LesConciergesGosu/GosuApp.git

Step 3: Install Dependencies
---------------

Now you can install the dependencies in your project. please go to the project folder than contains `Podfile`.

	$ cd PATH_OF_THE_PROJECT
    $ pod install

From now on, be sure to always open the generated Xcode workspace (`.xcworkspace`) instead of the project file when building your project:

    $ open Gosu.xcworkspace

Ready to work!
--------------------

You may meet some issues while going through the above steps. Please contact the developer for more.


Next Steps
---------------

You can find even more articles like this one [on the wiki](https://github.com/GosuApp/wiki).
