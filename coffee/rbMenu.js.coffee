#
# rbMenu v1.8.0 // 2015.06.29 // AngularJS 1.2.13
# http://
#
# You may use rbMenu under the terms of the MIT license. Which means basically that
# means you are free to use rbMenu as long as this header is left intact.
# Copyright 2014 Roy Bottomley
#
# menu directive that displays a data structure as a horizontal or vertical menu
# basic data structure is a  menuItem === {text: displayText, menu_action: {action}, sub_menu: [menuItems]}
angular.module('rb-menu', [])
  .directive( 'rbMenu', ['$sce', '$timeout', '$compile',(  $sce, $timeout,$compile ) ->
    return {
    restrict: 'E',
    scope: {
      menu: '=menu',
      config: '=config',
      buttonImage: '=buttonImage',
      forceSmallScreen: '=forceSmallScreen'
    },

    templateUrl: "rbMenu/rbMenu.html",

    link: (scope, el, attrs) ->

      scope.config ||= {}

      # conditional styling for vertical dropdon menu
      scope.style = scope.config.style || {}

      # allow vertical dropdon menu to be forced to be open
      scope.forceOpen = scope.config.force_open || false

      # prevent offclick from closing a vertical or repsonsive menu
      scope.preventOffclickClose  = !!scope.config.prevent_offclick_close

      # prevent a lineclick from closing a vertical or repsonsive menu
      scope.preventLineclickClose  = !!scope.config.prevent_lineclick_close

      # the string used with $emit to communication with owning controller
      scope.emitId = scope.config.emit_id || 'rb-nav-action'
      # whether a vertical menu is at the left or right side of the containing div
      scope.onLeft = !!scope.config.on_left
      # when in responsive mode switches to a responsive menu when the screen size is below these limits
      scope.mobileWidth = scope.config.mobile_width || 800
      scope.mobileHeight = scope.config.mobile_height || 600

      # allows the parent div to be placed at the top of the screen when in responsive mode
      scope.primaryMenu =  !!scope.config.primary_menu

      # an array which will be loaded with any menu images os they can be preloaded
      scope.images_to_wait_for = []

      # use the menu_type configuration input to determine whether to
      # display as a vertical or horizontal menu
      # display a button or opened 1st level menu
      # and whether to respond to screen size changes
      if scope.config.menu_type == 'vertical'
        scope.showAsTopbar  = false
        scope.disableMobileDectect = true
        scope.hideDropdownButton  = true
      else if scope.config.menu_type == 'horizontal'
        scope.showAsTopbar  = true
        scope.disableMobileDectect = true
        scope.hideDropdownButton  = false
      else
        scope.showAsTopbar  = false
        scope.disableMobileDectect = false
        scope.hideDropdownButton  = false

      # an ordered list of menus traversed used to close appropriate menus
      # when a different menu is opened
      scope.current_open_lines = []


      # position the directive depending on the type of menu required
      scope.initOrientation = () ->
        # position the rbMenu parent at the top of the screen
        # if the menu is a responsive menu and this is a primary menu
        if  !scope.disableMobileDectect && scope.primaryMenu
          el.parent().css({
          top: 0,
          left: 0,
          width: '100%',
          position: 'fixed',
          'z-index': 1000
          })

        # set the menu position and open/closed symbols
        # depending on whether a horizontal or vertical menu is required
        if scope.showAsTopbar
          el.css({
            top: 0,
            left: 0,
            width: '100%',
            display: 'block',
            position: 'relative',
            'z-index': 1000
          })
          scope.topbarClosedSymbol = scope.config.topbarClosedSymbol ||  "&#9660"
          scope.topbarOpenSymbol = scope.config.topbarOpenSymbol ||  "&#9660"
          scope.closedSymbol = scope.config.dropdownClosedSymbol ||  "&#9658"
          scope.openSymbol = scope.config.dropdownOpenSymbol ||  "&#9658"
        else
          if scope.onLeft
            side = 'left'
          else
            side = 'right'
          el.css({
            top: 0,
            left: 0,
            width: 'auto',
            float: side,
            display: 'inline-block',
            position: 'relative',
            'z-index': 1001
          })
          scope.closedSymbol = scope.config.dropdownClosedSymbol ||  "&#9660"
          scope.openSymbol = scope.config.dropdownOpenSymbol ||  "&#9658"

      # this method called from the template to determine whether
      # to include a left floating div in a hozitontal menu
      scope.hasTopLeftItems= () ->
        (item for item in scope.menu.sub_menu when item.left?).length > 0

      # this method called from the template to determine
      # which menu open or closed symbol to display
      scope.getMenuSymbol= (line) ->
        isTopBar = false
        if scope.showAsTopbar
          scope.checkKey(line)
          for li in scope.menu.sub_menu
            scope.checkKey(li)
            if li.key == line.key
              isTopBar = true
              break

        if isTopBar
          $sce.trustAsHtml(if scope.isOpen(line) then  scope.topbarOpenSymbol else scope.topbarClosedSymbol)
        else
          $sce.trustAsHtml(if scope.isOpen(line) then  scope.openSymbol else scope.closedSymbol)


      # adds a key to a line if one is not present
      scope.checkKey= (line) ->
        line.key = '_' + Math.random().toString(36).substr(2, 9) if !line.key?

      # determines if a line is open by looking for it in the list of currently opened lines
      # an open line has its display visible
      # A horizontal menu handles this with CSS and hovering
      scope.isOpen= (line) ->
        line? && (scope.showAsTopbar ||  # lines always open in horitontal menu
                  scope.forceOpen ||    # lines always open set be configuration
                  (li for li in scope.current_open_lines when li.key == line.key).length > 0)  ||  # its in the list of open lines
                  (scope.hideDropdownButton && line.key == scope.menu.key)  # its the root menu and no dropdown button is displayed

      # determines if the line being opened is in the currently open menu hierarchy
      # if so then close unused parts of the menu hierarchy
      # if not then close the complete hierarchy
      scope.closeIfNotChild= (line)->
        child = null
        #search the current open lines from the lowest level working upwards
        for openLine, index in scope.current_open_lines
          # check if the line being opened is in this lines sub_menu
          for li in openLine.sub_menu
            if li.key == line.key
              # record that the line being opened is a child in this lines sub_menu and exit loop
              child = true
              break
          # if the line being opened is in this lines sub_menu then we do not need to travel further up the  hierarchy
          # set the lines below this line as closed and exit loop
          if child?
            scope.current_open_lines = scope.current_open_lines[index..-1]
            break

        # if the line being opened is not a child of any open menus
        #then close the complete set of opened menus
        scope.current_open_lines = [] if !child?


      scope.offclickCloseLine= (line) ->
        scope.closeLine(scope.menu) unless scope.preventOffclickClose

      # closes a line and any lines below it in menu hierarchy
      scope.closeLine= (line) ->
        if line?
          if line.key == scope.menu.key
            scope.current_open_lines = []
          else
            for openLine, index in scope.current_open_lines
              if openLine.key == line.key
                scope.current_open_lines = scope.current_open_lines[index + 1..-1]
                break

      # opens a line if it has a sub menu
      # and closes and lines now not on the open menu hierarchy
      scope.openLine= (line) ->
        if line? && line.sub_menu
          scope.checkKey(line)
          scope.closeIfNotChild(line)
          scope.current_open_lines.unshift(line)


      # if a line is open close it
      # if a line is closed open it
      scope.toggleOpen= (line) ->
        if  scope.isOpen(line)
          scope.closeLine(line)
        else
          scope.openLine(line)

      # when a line is clicked toggle its open status if it has a sub_menu
      # and execute and menu_action if it has one
      scope.lineClicked= (line)->
        scope.toggleOpen(line) if line.sub_menu
        if line.menu_action && line.menu_action.emit?
          scope.$emit(scope.emitId, {lineClicked: line.menu_action.emit})
          scope.closeLine(scope.menu) unless scope.preventLineclickClose && !line.alwaysClose

      # checks to see any buton image specified is valid
      # if so and when it is loaded then change the CSS button displayed
      # to the loaded image
      scope.checkImage= (src) ->
        scope.hasImage = false
        if src?
          image = new Image();
          image.onerror= () =>
            scope.hasImage = false
          image.onload= () =>
            scope.hasImage = true

          image.src = src

      # search through all the menu and identify any images
      # save the soureof these images in an array so they can be preloaded
      scope.find_images_to_wait_for= (lines) =>
        for line in lines
          scope.images_to_wait_for.push(line.img_url) if line.img_url
          scope.find_images_to_wait_for(line.sub_menu) if line.sub_menu

      # preload images in an array
      # and increment a counter to show when all images have been checked
      scope.preload_images= () ->
        for src in scope.images_to_wait_for
          image = new Image()
          image.onerror= () =>
            scope.$apply(() -> scope.images_not_loaded -= 1)
          image.onload= () =>
            scope.$apply(() -> scope.images_not_loaded -= 1)
          image.src = src

      # if responsive menu is enabled then
      # compare the screen size with the configured limit to determine
      # whether the responsive menu should be displayed
      scope.detectMobile= () ->
        isMobile = scope.forceSmallScreen || (window.innerWidth <= scope.mobileWidth && window.innerHeight <= scope.mobileHeight)
        if (scope.showAsTopbar != !isMobile) && !scope.disableMobileDectect
          scope.showAsTopbar = !isMobile
          scope.$emit(scope.emitId, {menuTypeChange: scope.showAsTopbar })
        scope.initOrientation()


      # check top level menu has a key so it can be recognised
      scope.checkKey(scope.menu)

      # initialise the menu type and orientation
      scope.detectMobile()
      # load any button image
      scope.checkImage(scope.buttonImage)
      # preload any menu images
      scope.find_images_to_wait_for(scope.menu.sub_menu)
      scope.images_not_loaded = scope.images_to_wait_for.length
      scope.preload_images()

      # timeout on preloading the images os the menu is displayed after 2 seconds max
      $timeout( () =>
        scope.images_not_loaded = 0
      , 2000)

      # watch the window size and change the menu if needed
      $(window).on("resize.doResize", () ->
        scope.$apply( ()->
          scope.detectMobile()
        )
      )

      # scroll a responsive emnu in case it is taller than the screen size
      $(window).on("scroll", () ->
        if !scope.showAsTopbar  && !scope.disableMobileDectect
          if !scope.topStart?
            scope.topStart = $('#dd-holder').offset().top  - $(window).scrollTop()
          newTop = scope.topStart - $(window).scrollTop()
          $('#dd-holder').offset({ top: newTop})
      )

      # tear up the events if we are destroyed
      scope.$on("$destroy", () ->
        $(window).off("resize.doResize")
      )

      # watch an inout which allows a external variable to force
      # the menu into a responsive menu
      scope.$watch('forceSmallScreen', (value, oldValue) ->
        scope.detectMobile()
      )

    }
  ])

  # some simple methods for manipulating the data structure used in rbMenu directive
  .service('rbMenuService', [
    class rbMenuService
      constructor: () ->

      # adds a key to a menu item if it does not have one
      checkKey: (menuItem) ->
        menuItem.key = '_' + Math.random().toString(36).substr(2, 9) if !menuItem.key?

      # takes an array of MenuItems and returns for the one with the given key
      # if none can be found an new menuItem is generated
      # the new menu item is either blank or contains data from the newItem input
      # this will cause the rbMenu directive to update its display with the new item if one was added
      getMenuItem: (key, menuList, newItem = {}) ->
        menuItem = (item for item in menuList when item.key == key)[0]
        if !menuItem?
          menuItem = newItem
          @checkKey(menuItem)
          menuList.push(menuItem)
        menuItem

      # takes an array of MenuItems and returns for the one with the given key
      # find menu with the given key and updates teh given attribute
      setMenuAttribute: (key, menuList, attribute, newdata) ->
        menuItem = @getMenuItem(key, menuList)
        menuItem[attribute] = newdata

      # takes an array of MenuItems and removes the menuItem with the given key
      # this will cause the rbMenu directive to update its display with the new item
      removeMenuItem: (key, menuList) ->
        for item, index in menuList
          if item.key == key
            menuList.splice( index,1)
            break

      # takes an array of MenuItems
      # and replaces the item with the given key with the supplied newItem
      # this will cause the rbMenu directive to update its display with the new item
      replaceMenuItem: (key, menuList, newItem) ->
        @removeMenuItem(key, menuList)
        @checkKey(newItem)
        menuList.push(newItem)

  ])
