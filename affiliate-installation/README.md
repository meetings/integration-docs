# Meetin.gs affiliate documentation

Meetin.gs registered affiliates can add Meet Me -buttons on their users profiles to facilitate easy meeting scheduling. This document also details how Meetin.gs can be used to easily implement rich user listings.

## Setup process

### 1. Register an application to get an API key

For now registration is done manually by emailing to antti@meetin.gs. We will create you an application that is initially set up in development mode and can return data for a couple of USER\_TOKENs provided by our test CSV file. After initial development you can can choose from several ways to handle the USER\_TOKEN translation.

For testing purposes you can use "test" as an API key. You can see an example gallery using "test" -API key here: [platform.meetin.gs](http://platform.meetin.gs)

### 2. Install our script on your site

Add the following script tag with your API key on the pages you want to use the Meet Me -buttons. The script will find all Meet Me button elements and Meet Me list elements on pageload and convert them to Meet Me -buttons.

##### Tag

    <script type="text/javascript" id="mtn_script" data-api-key="YOUR_API_KEY"
        src="https://platform.meetin.gs/mtn.js" defer="defer"></script>

##### Required attributes

    data-api-key - Your application ID

##### Additional attributes

    data-current-user-token - token which is used to determine if a button belongs to currenty logged in user
    data-disable-unregistered - if set to 1, buttons are not shown for users who have not registered to Meetin.gs
    data-disable-autoinit - if set to 1, MTN.init() is not called on page load automatically

If you add/change page content dynamically, you can always use the following call to intialize the new Meet Me -buttons currently on the page.

    MTN.init();

### 3. Add button or button list markup to add buttons

##### Button markup

Adding the following markup will create a Meet Me -button pointing to the user matching USER\_TOKEN:

    <script type="MTN/button" data-token="USER_TOKEN"></script>

##### Button list markup

Adding the following markup will create a list of meet me buttons for all users in the associated application backend (currently only for the CSV listing backend):

    <script type="MTN/list"></script>

##### Additional attributes for both markups

If one of these attributes is given for the button list markup, they will be added to all resulting buttons.

    data-mode - full|button
    data-type - meetme|schedule
    data-color - blue|silver|gray|dark
    data-disable-organization - If set to 1, no organization is included in the full button 
    data-disable-title - If set to 1, no title is included in the full button
    data-disable-first-name - If set to 1, no first name is included in the full button
    data-disable-last-name - If set to 1, no last name is included in the full button

##### Additional attributes fot button list markup

    data-match - For example the value "Department=Sales" would limit the list of people to those who have the custom "Department" -field set to "Sales".

### 4. Provide a method for translating USER\_TOKENs to emails

In Meetin.gs users are identified by their email, but we don not want you to place those emails to customers' client side pages. Thus we need a way for you to translate the USER\_TOKEN values you use to the actual user emails you want to query.

Currently Meetin.gs supports two main options: 1. A URL to a properly formatted CSV file and 2. A HTTP service for the translations. These approaches are detailed further in the upcoming subsections.

A method relying on symmetric encryption of the emails is on the roadmap and will be prioritized according to developer interest.

#### 4.1 Option 1: Provide a URL to a properly formatted CSV

A properly formatted CSV file must be UTF-8 encoded, must contain unique column names as the first row and must contain the column names "TOKEN" and "EMAIL" (case insensisive). Here is the CSV spec we honor: http://tools.ietf.org/html/rfc4180

The CSV file can also contain additional columns, all of which are passed to the Meetin.gs button customization infrastructure as named parameters. If an additional column conflicts with one of Meetin.gs provided additional columns, the value acts as a default value. Default values will be replaced with Meetin.gs values if the user in question has registered to Meetin.gs and the information in question has been provided for that user.

We encourage using a Google Spreadsheets document which can be easily shared in CSV form using an URL. You can for example duplicate the test document that is used to generate the initial testing CSV:

https://docs.google.com/a/dicole.com/spreadsheet/ccc?key=0AqnOWbpvdZ0qdFRUM0lTeDdnblBQekxiajdVSGduSWc

#### 4.2 Option 2: Provide a HTTP service for the translations

When a request to display a Meetin.gs scheduler button arrives from the client, Meetin.gs sends a HTTP GET request to an URL that you have specified. Two query parameters are added to the URL, overwriting existing parameters if they exist:

    token - the user token that should be used to look up the email of the target user
    checksum - not implemented yet

Your HTTP endpoint should return with a simple UTF-8 encoded JSON object structure that contains at least the key "email".

The response object can also contain additional keys, all of which are passed to the Meetin.gs button customization infrastructure as named parameters. If an additional column conflicts with one of Meetin.gs provided additional columns, the value acts as a default value. Default values will be replaced with Meetin.gs values if the user in question has registered to Meetin.gs and the information in question has been provided for that user.

##### Request that Meetin.gs makes to your site

    GET https://yoursite.com/secret_token_to_email_url/?token=USER_TOKEN&checksum=CHECKSUM

##### Response you send on success

    Status: 200 OK
    
    Required response body:
    {
        "EMAIL" : "user@email.com"
    }
    
    Optional response body example:
    {
        "EMAIL" : "user@email.com",
        "First name" : "Bill",
        "Last name" : "Anderson",
        "Title" : "CTO",
        "Organization" : "Matrix Corp",
        "Your custom parameter" : "your_value"
    }

##### Response you send for users that can not be found
    
    Status: 404 Not found

Currently the only security feature for your endpoint is that the endpoint URL should be secret and the requests should go over HTTPS. A further feature for verifying that the sender of the request is indeed Meetin.gs, we will offer a way to calculate a SHA1 hash composed of the USER\_TOKEN and an application specific shared secret.

### 5. OPTIONAL: Override button visual rendering

In some cases custom visuals and custom functionality using the backend extra parameters are required. For this purpose you can define a function to handle rendering of an individual's representation in the list.

The function will receive three parameters:

    1. HTML node of the "script" tag that denotes the place where the button should be rendered
    2. Javascript Object which contains all the default and additional parameters as keys
    3. Value 1 or 0 indicating if this button should be rendered for the currently logged in user

The function is called immediately when the users data has been received and they should replace the received node in the DOM with the individual's representation.

The function can be defined in a javascript object that is defined before the script executes with the following syntax:

    <script type="text/javascript">
        window.MTN = window.MTN || {};
        window.MTN.custom_user_data_received_handler = function( node, data, for_self ) {
            // Your custom rendering here
        };
     </script>

Or if you are calling MTN.init() from your own code you can pass the custom render function like so:

    MTN.init({ custom_user_data_received_handler : function( node, data, for_self ) { 
        // Your custom rendering here
    }});
