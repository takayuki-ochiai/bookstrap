#--------------------------------------------------------------------------*
# *  
# *  heightLine JavaScript Library beta4
# *  
# *  MIT-style license. 
# *  
# *  2007 Kazuma Nishihata 
# *  http://www.webcreativepark.net
# *  
# *--------------------------------------------------------------------------
new ->
  heightLine = ->
    @className = "heightLine"
    @parentClassName = "heightLineParent"
    reg = new RegExp(@className + "-([a-zA-Z0-9-_]+)", "i")
    objCN = new Array()
    objAll = (if document.getElementsByTagName then document.getElementsByTagName("*") else document.all)
    i = 0

    while i < objAll.length
      eltClass = objAll[i].className.split(/\s+/)
      j = 0

      while j < eltClass.length
        if eltClass[j] is @className
          objCN["main CN"] = new Array()  unless objCN["main CN"]
          objCN["main CN"].push objAll[i]
          break
        else if eltClass[j] is @parentClassName
          objCN["parent CN"] = new Array()  unless objCN["parent CN"]
          objCN["parent CN"].push objAll[i]
          break
        else if eltClass[j].match(reg)
          OCN = eltClass[j].match(reg)
          objCN[OCN] = new Array()  unless objCN[OCN]
          objCN[OCN].push objAll[i]
          break
        j++
      i++
    
    #check font size
    e = document.createElement("div")
    s = document.createTextNode("S")
    e.appendChild s
    e.style.visibility = "hidden"
    e.style.position = "absolute"
    e.style.top = "0"
    document.body.appendChild e
    defHeight = e.offsetHeight
    changeBoxSize = ->
      for key of objCN
        if objCN.hasOwnProperty(key)
          
          #parent type
          if key is "parent CN"
            i = 0

            while i < objCN[key].length
              max_height = 0
              CCN = objCN[key][i].childNodes
              j = 0

              while j < CCN.length
                if CCN[j] and CCN[j].nodeType is 1
                  CCN[j].style.height = "auto"
                  max_height = (if max_height > CCN[j].offsetHeight then max_height else CCN[j].offsetHeight)
                j++
              j = 0

              while j < CCN.length
                if CCN[j].style
                  stylea = CCN[j].currentStyle or document.defaultView.getComputedStyle(CCN[j], "")
                  newheight = max_height
                  newheight -= stylea.paddingTop.replace("px", "")  if stylea.paddingTop
                  newheight -= stylea.paddingBottom.replace("px", "")  if stylea.paddingBottom
                  newheight -= stylea.borderTopWidth.replace("px", "")  if stylea.borderTopWidth and stylea.borderTopWidth isnt "medium"
                  newheight -= stylea.borderBottomWidth.replace("px", "")  if stylea.borderBottomWidth and stylea.borderBottomWidth isnt "medium"
                  CCN[j].style.height = newheight + "px"
                j++
              i++
          else
            max_height = 0
            i = 0

            while i < objCN[key].length
              objCN[key][i].style.height = "auto"
              max_height = (if max_height > objCN[key][i].offsetHeight then max_height else objCN[key][i].offsetHeight)
              i++
            i = 0

            while i < objCN[key].length
              if objCN[key][i].style
                stylea = objCN[key][i].currentStyle or document.defaultView.getComputedStyle(objCN[key][i], "")
                newheight = max_height
                newheight -= stylea.paddingTop.replace("px", "")  if stylea.paddingTop
                newheight -= stylea.paddingBottom.replace("px", "")  if stylea.paddingBottom
                newheight -= stylea.borderTopWidth.replace("px", "")  if stylea.borderTopWidth and stylea.borderTopWidth isnt "medium"
                newheight -= stylea.borderBottomWidth.replace("px", "")  if stylea.borderBottomWidth and stylea.borderBottomWidth isnt "medium"
                objCN[key][i].style.height = newheight + "px"
              i++
      return

    checkBoxSize = ->
      unless defHeight is e.offsetHeight
        changeBoxSize()
        defHeight = e.offsetHeight
      return

    changeBoxSize()
    setInterval checkBoxSize, 1000
    window.onresize = changeBoxSize
    return
  addEvent = (elm, listener, fn) ->
    try
      elm.addEventListener listener, fn, false
    catch e
      elm.attachEvent "on" + listener, fn
    return
  addEvent window, "load", heightLine
  return