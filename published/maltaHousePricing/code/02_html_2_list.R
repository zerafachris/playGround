html_2_list <- function(XX) {
  # FUNCTION WHICH PARSES HTML AND CONVERTS TO LIST
  # XX <- "./02_data_RAW/20150423_prop_for_sale_tom_classifieds.html"
  doc.html <- htmlTreeParse(XX,useInternal = TRUE) #PARSE HTML FILE
  doc.text <- unlist(xpathApply(doc.html,
                                '//p | //*[(@id = "section_section")]//*[contains(concat( " ", @class, " " ), concat( " ", "default_top_margin", " " ))]',
                                xmlValue)) # EXTRACT h2 AND p FROM HTML STRUCTURE
  # dates have maximum 30 characters and at least 19
  # Wednesday (9), Sunday(6)
  # Septermber (9), May (3)
  # nchar= 9(VAR) + 2 + 9(VAR) +1+2+2+4 = 29
  dates <- doc.text[which(nchar(doc.text)<= 30 & nchar(doc.text) >= 19)] # DATES FROM CHARACTERS
  # concatenate date with row entry
  c = 0 # COUNTER
  for (i in seq(1,length(doc.text))) { #OVER ALL ENTRIES IN LIST
    if (doc.text[i] %in% dates) # CHECK IF ITEM IN LIST IS A DATE
    { #IF YES, CONCATENATE THE DATE AND SUBSEQUENCT ROWS WITH THE DATE FROM date
      c=c+1
      doc.text[i] <- paste(substring(XX,15,22), dates[c],doc.text[i],sep = " ")
    } else {
      doc.text[i] <- paste(substring(XX,15,22), dates[c],doc.text[i],sep = " ")
    }
  }
  # Longest char string with non-sense is:
  # Date_\nProperty For Sale\nPROPERTY FOR SALE" (59char)
  # For longest date, nchar would be 67
  doc.text <- doc.text[which(nchar(doc.text) >= 68)]
  
  doc.text <- stri_trans_general(doc.text,"Latin-ASCII") # remove special letters
  doc.text <- gsub('€','[euro]',doc.text) # replace euro symbol with euro text 
  doc.text <- gsub('\n',' ',doc.text) # replace \n with space
  # html where not all consistent. had to replace errors
  doc.text <- gsub('\\btrrowrowd\\b',' ',doc.text) # replace trrowrowd with space
  doc.text <- gsub('och','',doc.text) # replace och with empty
  doc.text <- gsub('GoBack','',doc.text) # replace GoBack with empty
  doc.text <- gsub('\\.',' ',doc.text) # replace fullstops with space
  doc.text <- gsub('\\,[a-zA-Z]',' ',doc.text) # replace commas next to letters
  
  # split list into 2 if it contains 'MailEndCompose'
  xx <- str_split(doc.text,'MailEndCompose') # identify which item contain MailEndCompose
  cc=0 #counter
  XX = NA # variable to be filled
  for (i in seq(1,length(xx))){ #i<-2 ITERATE OVER list of items
    if ( length(xx[[i]]) == 3 ){ # if number of items is 3, can split into 2
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
    } else if ( length(xx[[i]]) == 4 ){ # if number of items is 4, can split into 3
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
    } else if ( length(xx[[i]]) == 5 ){ # etc
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      d <- paste(xx[[i]][1],xx[[i]][5],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
      cc=cc+1
      XX[cc] <- d
    }
  }
  doc.text <- doc.text[!grepl("MailEndCompose", doc.text, ignore.case = FALSE)] # remove items with contain MailEndCompose from list
  doc.text <- c(doc.text,XX) # merge new list with list w/o MailEndCompose
  # remove doubled locations
  doc.text <- gsub('Property For Sale\\s[A-Z]+\\s\\s\\sProperty','Property',doc.text)
  # split list into 2 if it contains 'OLE_LINK1'
  xx <- str_split(doc.text,'OLE_LINK1') # identify which item contain MailEndCompose
  cc=0 #counter
  XX = NA # variable to be filled
  for (i in seq(1,length(xx))){ #i<-2 ITERATE OVER list of items
    if ( length(xx[[i]]) == 3 ){ # if number of items is 3, can split into 2
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
    } else if ( length(xx[[i]]) == 4 ){ # if number of items is 4, can split into 3
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
    } else if ( length(xx[[i]]) == 5 ){ # etc
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      d <- paste(xx[[i]][1],xx[[i]][5],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
      cc=cc+1
      XX[cc] <- d
    }
  }
  doc.text <- doc.text[!grepl("OLE_LINK1", doc.text, ignore.case = FALSE)] # remove items with contain MailEndCompose from list
  doc.text <- c(doc.text,XX) # merge new list with list w/o OLE_LINK1
  
  # split list into 2 if it contains ' ine '
  xx <- str_split(doc.text,'ine [A-Z]') # identify which item contain MailEndCompose
  cc=0 #counter
  XX = NA # variable to be filled
  for (i in seq(1,length(xx))){ #i<-2 ITERATE OVER list of items
    if ( length(xx[[i]]) == 3 ){ # if number of items is 3, can split into 2
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
    } else if ( length(xx[[i]]) == 4 ){ # if number of items is 4, can split into 3
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
    } else if ( length(xx[[i]]) == 5 ){ # etc
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      d <- paste(xx[[i]][1],xx[[i]][5],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
      cc=cc+1
      XX[cc] <- d
    }
  }
  doc.text <- doc.text[!grepl("ine [A-Z]", doc.text, ignore.case = FALSE)] # remove items with contain ine [A-Z] from list
  doc.text <- c(doc.text,XX) # merge new list with list 

  # split list into 2 if it contains ' {_'
  xx <- str_split(doc.text,'\\{_') # identify which item contain MailEndCompose
  cc=0 #counter
  XX = NA # variable to be filled
  for (i in seq(1,length(xx))){ #i<-2 ITERATE OVER list of items
    if ( length(xx[[i]]) == 3 ){ # if number of items is 3, can split into 2
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
    } else if ( length(xx[[i]]) == 4 ){ # if number of items is 4, can split into 3
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
    } else if ( length(xx[[i]]) == 5 ){ # etc
      a <- paste(xx[[i]][1],xx[[i]][2],sep="")
      b <- paste(xx[[i]][1],xx[[i]][3],sep="")
      c <- paste(xx[[i]][1],xx[[i]][4],sep="")
      d <- paste(xx[[i]][1],xx[[i]][5],sep="")
      cc=cc+1
      XX[cc] <- a
      cc=cc+1
      XX[cc] <- b
      cc=cc+1
      XX[cc] <- c
      cc=cc+1
      XX[cc] <- d
    }
  }
  doc.text <- doc.text[!grepl("\\{_", doc.text, ignore.case = FALSE)] # remove items with contain \\{_ from list
  doc.text <- c(doc.text,XX) # merge new list with list 
  return(doc.text)
}