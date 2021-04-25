## Hello and Thank You for Visiting!

### Testing for MachineKit.io and Codelabs...

# So, first...

    1. We need to go to https://golang.org/dl/
       -- do not use your package manager. Install go like the site says.
    2. Then, we need to get node.js from https://nodejs.org/en/download/
       -- again, not w/ the package manager! Install it w/ the binary.
    3. We need to install claat by --- go get github.com/googlecodelabs/tools/claat --- 
       -- Or, you can follow these instructions: 
       -- https://github.com/googlecodelabs/tools/tree/master/claat#install

## Secondly, we...

    1. https://medium.com/@zarinlo/publish-technical-tutorials-in-google-codelab-format-b07ef76972cd
       -- This site can be followed or you can just follow along on "Thirdly!"

### Thirdly, one must...

    1. export GOPATH=$HOME/go (or wherever the go install is located on your filesystem...

    2. export GOROOT=/usr/local/go

    3. export PATH=$PATH:$HOME/go/bin

    4. if chosen, move claat to $HOME/go/bin

    5. make claat executable with chmod u+x claat in the claat dir.

    6. git clone https://github.com/googlecodelabs/tools will get you the
       necessary tools...

    7. cd site/

    8. npm install

    9. npm install -g gulp-cli

    10. If npm has issues w/ the install of gulp-cli, uninstall gulp and
        reinstall it with npm and then proceed to install gulp-cli

### Fourthly:

    1. gulp serve
       -- This will bring you to a command line interface stating
          where to go online on a local server to see your codelabs...

    2. Stop the server w/ Control-C

    3. go into the site/ directory and create a codelabs dir.
       -- mkdir codelabs
       -- cd codelabs

    4. create and directory called assets by ``` mkdir assets ```

    5. create a file in the /site/codelabs/ dir. and call it writing_codelabs.md
       
       summary: How to Write a Codelab
       id: writing_codelabs
       categories: Sample
       tags: medium
       status: Published 
       authors: You
       Feedback Link: Your_Contact_info_if_available!

       # How to Write a Codelab
       <!-- ------------------------ -->
       ## Overview 
       Duration: 1

       ### Images
       ![alternate-text](assets/morphing.jpg)

       <!-- ------------------------ -->
       
       
       
    6. claat export writing_codelabs.md

### This has been brought to you by me and the fellow that produced the info...

    1. If you want to see the morphing.jpg, please place the photo in
       /site/codelabs/assets/ and actually have a photo called morphing.jpg in assets like this...
       /site/codelabs/assets/morphing.jpg.

    2. go into the codelabs dir. and type claat export writing_codelabs.md

    3. go into your /site/ dir. and type gulp serve --codelabs-dir=codelabs

    4. That should have turned your markdown language into html on the landing page...

    5. Now, you can freely go to your localhost:8000/ server in the address bar

    6. You can now click your newly formed codelabs .md turned .html file(s). Enjoy!

# If at some point, this gets too much fun, send kudos. 

# Build via included Dockerfile

## Run `docker build` command

```
docker build -t mkh-codelabs --build-arg DEBIAN_DISTRO_BASE=ubuntu:focal .
```

## Run `docker run` command

```
docker run -it --rm -u "$(id -u):$(id -g)" -p 8000:8000 --network host -w /home/machinekit/gcl_tools/site mkh-codelabs:latest gulp serve
```

## Test in browser

Load address `localhost:8000` in web browser.

