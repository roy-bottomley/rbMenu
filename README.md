# rbMenu
An AngularJS directive that provides a data driven menu which can be configured as a horizontal, vertical or responsive menu of any depth.
This is written for my own use as I couldn't find a suitable menu directive for my needs. It allows me to keep menu configerations for users in the database and can be used as a horizontal vertical or rsponsive menu with several configuration options. Its released under MIT license so feel free to use if its helpful to you.
## Demo
- [A demo page](http://www.roy-bottomley.com/demos/rbmenu)
- [in action in an application](http://www.tacticalfootball.com/clubs/1122)

## Features
* **Dynamic content:**  When the menu data structure changes the menu is updated.
* **Simple to use:**  just add the directive  <rb-menu config = 'myconfig', menu = 'myMenu'>
* **Data Driven:** A simple hash for each menu item, each hash can contain an array of similar hashes as a sub menu. Described below.
* **MultiLevel:** The use of recursion means you can add as many menu levels as you need.
* **Many customizable options:** such as orientation, behaviour, tool tips, callbacks ... Described below.
* **CSS animations:** CSS animations for collapsing and expanding menu items. 

## Usage
1. Download and install the coffeescript and scss files where they will be compiled and included in your apps javascript and the haml files where they can be accessed by Angular.</li>
I'm using RoR. With Rails you would
place the coffeescript files in app/assets/javascript and make sure they are included in application.js
I use the gem ['angular-rails-templates'](https://github.com/pitr/angular-rails-templates) nd place the haml files in app/assets/templates/rbMenu. Finally place the scss file in app/assets/stylesheets and make sure it is included in application.css

2. The functionality that closes the menu when a click occurs away from the menu is provided by the 
[angular-off-click directive](https://github.com/TheSharpieOne/angular-off-click) 
If you want this functionality then download and install Offclick.


3. Menu animation is provided by [ngAnimate](https://docs.angularjs.org/api/ngAnimate). Make sure this is available. 
The easiest way is to load it from the same cdn that provides your Angular e.g.
["https://ajax.googleapis.com/ajax/libs/angularjs/1.2.13/angular-animate.min.js"]("https://ajax.googleapis.com/ajax/libs/angularjs/1.2.13/angular-animate.min.js"}). </li>
Some nice animations to use with this can be found at [Animate.css](https://daneden.github.io/animate.css/). To use these downlad animate.css and include it in your app.

4. Inject 'rb-menu' into your apps main angular module</li>
e.g. if using angular-rails-templates, ngAnimate and Offclick then </li>
>  angular.module('myModule', ['templates', 'rb-menu', 'ngAnimate','offClick'])

5. Create a menu
e.g 
> myTopMenu = {text: 'My Menu', sub_menu[{text: "Roy Bottomley's Home Page", menu_action: {url: 'http://www.roy-bottomley.com'}}]}
</li>

> myMenu = {sub_menu: [myTopMenu]}

6. Add the directive to your html
e.g. 
> <rb-menu config = 'myconfig', menu = 'myMenu'>

Check out the [Github for the demo page](https://github.com/roy-bottomley/Demo-for-rbMenu.git) for a complete working example.

## Data Structure
The top level menu passed into the directive is a MENUITEM with no contents except a sub_menu
> {sub_menu: [ array of MENUITEMS] }

A **MENUITEM** is a hash with the following key/value pairs
* **alwaysClose:** A boolean, If true overrides the prevent_lineclick_close configuration.
* **class:** A string which will be inserted into the menu item as a css class.
* **divider:**  A boolean, If true a divider line is displayed under the menu
* **hide:**  A boolean, If true the menu item will not be displayed.
* **img_url:** URL of an image to be displayed in the menu item.
* **key:** A unique identifer, if one is not given then one will be generated.
* **left:** A boolean, If true the menu item will be displaced in a horizontal menus left section.
* **menu_action:** A MENUACTION hash (see below).
* **right:** A boolean, If true the menu item will be displaced in a horizontal menus right section.
* **sortKey:** mMenu items are displayed in ascending sortkey order.
* **sub_menu:** An array of MENUITEMS.
* **text:** Text which is displayed in the menu.
* **tooltip:** A string which will be displayed as a tooltip.

A **MENUACTION** is a hash with the following key/value pairs
* **url:** The URL to navigate to when the menu item is clicked
* **ui_sref:** The angular ui.route state to navigate to when the menu item is clicked
* **emit:** A hash to be sent to as data using $emit

## Configuration
Three inputs determine the directive behavior </li>

1. **buttonImage:** A URL of an image to be displayed as the dropdown button. Defaults to a standard drowndown menu image. 
</li>

2. **forceSmallScreen:** A boolean used in responsive mode. When true forces the directive to assume a smallscreen size and switch to a vertical menu.
</li>

3. **config:** A hash with the following key/value pairs used to configure the diretive. Default {}
* **style:** A string used to style the vertical menu using [ng-style](https://docs.angularjs.org/api/ng/directive/ngStyle). Default null.
* **force_open:** A boolean. When true forces all the sub_menus of a vertical dropdon menu to be forced to be open. Default false.
* **prevent_offclick_close:** A boolean. When true prevents a vertical sub_menu from closing when a click occurs away from the menu. Default false.
* **prevent_lineclick_close:** A boolean. When true prevents a vertical sub_menu from closing when a sub item is clicked on. Default false.
* **emit_id:** A string. This is the event identifier used to by $emit when an emit MENUACTION is clicked. Default 'rb-nav-action'
* **on_left:** A boolean. When true a vertical menu is on the left of the containing div else the menu is on the right. Default false.
* **mobile_width: & mobile_height:** When the screen size is less than mobile_width by mobile_height a responsive menu will display as a vertical dropdown at the side of the screen, otherwise it will display as a horizontal menu at the top of the screen. Default is 800 by 600		
* **primaryMenu:** A boolean when true a responsive menu will appear at the top of the screen when on a large screen, else it will appear at the top of the containing div. Default false.
* **menu_type:** One of
- 1. **vertical:** a vertical menu displayed at the left or right of the containing div. No dropdown button is displayed. 
- 2. **horizontal:** a horizontal menu displayed at the top of the containing div. 
- 3. **responsive:** This is the default if no menu_type is specified. The menu displayed is either vertical or horizontal depending on the screen size and the values of mobile_width and mobile_height. If a vertical menu is displayed a dropdown button is displayed and the top level menu closed.       

## Events
The directive enits events events with the name specified under the **emit_id** confirguation key. Two type of events are emitted.
1. When a MENUITEM is clicked and the MENUACTION has data under the **emit:** key then an event is generated with the data
> {lineClicked: MENUACTION[:emit] }

2. when a responsive menu changes state between horizontal or vertical menus then an event is generated with the data
> {menuTypeChange: TRUE if a horizontal menu is displayed }





