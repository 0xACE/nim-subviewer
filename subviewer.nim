

import times
import strutils
import sequtils


type
    SubViewerData* = ref SubViewerDataInternal
    SubViewerDataInternal* = object
        title* : string
        author* : string
        source* : string
        filePath* : string
        delay* : string
        comment* : string
        program* : string
        color* : string
        style* : string
        size* : string
        font* : string
        subtitles* : seq[SubViewerSubtitle]
    
    SubViewerSubtitle* = ref SubViewerSubtitleInternal
    SubViewerSubtitleInternal* = object
        startTime* : TimeInterval
        endTime* : TimeInterval
        startTimeString* : string
        endTimeString* : string
        text* : string


proc parseSubViewer*(subviewerData : string): SubViewerData = 
    ## Parses a string containing SubViewer data into a ``SubViewerData`` object.
    
    var sv : SubViewerData = SubViewerData(subtitles: @[], title: "", author: "", source: "", filePath: "", delay: "",
                                           comment: "", program: "", color: "", style: "", size: "", font: "")
    var svl : seq[string] = subviewerData.replace("\r\n", "\n").replace("\r", "\n").split("\n")
    
    var expectText : bool = false
    var expectInfo : bool = true
    for i in 0..high(svl):
        var row : string = svl[i]
        
        if row.strip(leading = true, trailing = true) == "":
            continue
        
        if expectInfo:
    
            if row.startsWith("[INFORMATION]"):
                continue
            
            elif row.startsWith("[TITLE]"):
                sv.title = row[7..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[AUTHOR]"):
                sv.author = row[8..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[SOURCE]"):
                sv.source = row[8..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[FILEPATH]"):
                sv.filePath = row[10..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[DELAY]"):
                sv.delay = row[7..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[COMMENT]"):
                sv.comment = row[9..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[PRG]"):
                sv.program = row[5..high(row)].strip(leading = true, trailing = true)
            
            elif row.startsWith("[END INFORMATION]"):
                expectInfo = false
            
            continue
        
        if row.startsWith("[SUBTITLE]"):
            expectInfo = false
            continue
        
        elif row.startsWith("[COLF]") or row.startsWith("[SIZE]") or row.startsWith("[STYLE]") or row.startsWith("[FONT]"):
            var stl : seq[string] = row.split(",")
            
            for item in stl:
                
                if item.startsWith("[COLF]"):
                    sv.color = item[8..high(item)].strip(leading = true, trailing = true)
                
                elif item.startsWith("[SIZE]"):
                    sv.size = item[6..high(item)].strip(leading = true, trailing = true)
                
                elif item.startsWith("[STYLE]"):
                    sv.style = item[7..high(item)].strip(leading = true, trailing = true)
                
                elif item.startsWith("[FONT]"):
                    sv.font = item[6..high(item)].strip(leading = true, trailing = true)
        
        else:
            
            var sub : seq[string] = svl[i..high(svl)].join("\n\n").strip(leading = true, trailing = true).split("\n\n")
            sub.keepItIf(it.strip(leading = true, trailing = true) != "")
            
            for i in countup(0, high(sub), 2):
                var r1 : string = sub[i]
                var r2 : string = sub[i + 1]
                var st : SubViewerSubtitle = SubViewerSubtitle()
                
                var dSplit : seq[string] = r1.split(",")
                st.startTimeString = dSplit[0]
                st.endTimeString = dSplit[1]
                st.startTime = initInterval(milliseconds = parseInt(st.startTimeString[9..10]) * 10, seconds = parseInt(st.startTimeString[6..7]),
                                            minutes = parseInt(st.startTimeString[3..4]), hours = parseInt(st.startTimeString[0..1]))
                st.endTime = initInterval(milliseconds = parseInt(st.endTimeString[9..10]) * 10, seconds = parseInt(st.endTimeString[6..7]),
                                          minutes = parseInt(st.endTimeString[3..4]), hours = parseInt(st.endTimeString[0..1]))
                st.text = r2.replace("[br]", "\n")
                
                sv.subtitles.add(st)
                
                if i + 1 == high(sub):
                    break
            
            break
    
    return sv
            


var s : SubViewerData = parseSubViewer(readFile("example.sub"))   
for r in s.subtitles:
    echo(r.startTimeString)
    echo(r.endTimeString)
    echo(r.text)