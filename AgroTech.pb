#Program_Name = "Agro Tech"
#Program_Version = "1.0"
#DataBase_Version = "26.04.2012"

#epsilon = 0.07 ; Нормативний коефіцієнт ефективності капіталовкладень 

Enumeration
  #Window_0
  #Window_1
  #Menu
  #MenuAbout
  #MenuCheck
  #MenuClose
  #MenuGospodarstva
  #MenuCulture
  #MenuTractors
  #MenuMashinery
  #MenuOperations
  #MenuAreas
  #MenuMTA
  #MenuTechCards
  #MenuModel
  #MenuFixed
  #MenuGraf
  #StatusBar
  #Container_0
  #Container_1
  #WinWidth = 910
  #WinHeight = 600
  #Text_0
  #Toolbar
  #ToolAddButton
  #ToolSaveButton
  #ToolDeleteButton
  #ToolExpButton
  #ToolCloseButton
  #icon1
  #icon2
  #icon3
  #icon4
  #Splitter_1
  #grid
  #Panel
  #Listicon_0
  #Listicon_1
  #Listicon_2
  #Listicon_3
  #Listicon_4
  #Listicon_5
  #Editor_1
  #Button_0
  #Button_1
  #Button_2
  #Tree_0
  #PB_ListIcon_JustifyColumnLeft
  #PB_ListIcon_JustifyColumnCenter
  #PB_ListIcon_JustifyColumnRight
EndEnumeration

XIncludeFile "RaGrid.pbi"
;XIncludeFile "PureXLS.pbi"

Global ListGadget.l 

Declare.l NotifyCallback(WindowID.l, Message.l, wParam.l, lParam.l) 
Declare Gospodarstva()
Declare Culture()
Declare Operations()
Declare Tractors()
Declare Mashinery()
Declare Areas()
Declare MTA()
Declare TechCards()
Declare Model()
Declare Fixed()
Declare Grafik()
Declare StatusUpdate (BaseRequest.s)
Declare MainMenu (MainMenuitem.l)
Declare Show_FloatingBars (hParentDlg.l, date.l)

; Прототипи функцій бібліотеки лінійного програмування
Prototype  read_LP(filename.s,verbose.l,lprec.s)
Prototype  solve(lprec.l)
Prototype  set_outputfile(lprec.l, file.s)
Prototype  print_solution(lprec.l, cols.l)
Prototype  print_objective(lprec.l)
Prototype  get_objective(lprec.l)
Prototype  delete_lp(lprec.l)
Global New_read_lp.read_LP
Global solve.solve
Global printf.set_outputfile
Global printsol.print_solution
Global printob.print_objective
Global objective.get_objective
Global del.delete_lp

;Оголошення структури для гриду
  Structure Grid1
    col0.l
    col1.s
    col2.s
    col3.s
  EndStructure
  
Procedure SetListIconColumnJustification(ListIconID, Column, Alignment)
  
      Protected ListIconColumn.LV_COLUMN
      ListIconColumn\mask = #LVCF_FMT
      Select Alignment
        Case #PB_ListIcon_JustifyColumnLeft
          ListIconColumn\fmt = #LVCFMT_LEFT
        Case #PB_ListIcon_JustifyColumnCenter
          ListIconColumn\fmt = #LVCFMT_CENTER
        Case #PB_ListIcon_JustifyColumnRight
          ListIconColumn\fmt = #LVCFMT_RIGHT
      EndSelect
      SendMessage_(GadgetID(ListIconID), #LVM_SETCOLUMN, Column, @ListIconColumn)
  
EndProcedure
   
Procedure StatusUpdate (BaseRequest.s)
  StatusBarText(#StatusBar, 0, " Файл: <DataBase.sqlite> (" + StrF(FileSize("DataBase.sqlite")/1024,1) + " КБ)") 
  StatusBarText(#StatusBar, 3, "Останній запис у базі:  " + FormatDate("%dd.%mm.%yyyy  %hh:%ii", GetFileDate("DataBase.sqlite", #PB_Date_Modified)))
  If BaseRequest <> ""
    If DatabaseQuery(0,BaseRequest) <> 0
      NextDatabaseRow(0)
      StatusBarText(#StatusBar, 1," Кількість записів у таблиці:  " + GetDatabaseString(0, 0)) 
    EndIf    
  Else 
    StatusBarText(#StatusBar, 1, "") 
  EndIf  
  FinishDatabaseQuery(0)  
EndProcedure

Procedure Show_FloatingBars(hParentDlg.l, date.l)
  Protected i.l
  Protected nC.l
  Protected nRetVal.l
  Protected szTemp.s;{2000}
  Dim aData.d(11)
  ACount.l = 0
  nChangeData = #False ; disallow changing the data with a mouseclick                    
  KillTimer_(hParentDlg,1) ; Kill the timer 
  If nIsChart2
    RMC_DeleteChart(2048)
    nIsChart2 = 0  ; If second chart is existing, delete it
  EndIf
    
  If RMC_CreateChart(hParentDlg,2048,5,50,935,580,#ColorWhite,#RMC_CTRLSTYLE3DLIGHT,#False,"","Tahoma") = #RMC_NO_ERROR ;#ColorLightGray
    
    psSQLRequest.s = "SELECT [gospodarstva].[Name], [cultures].[Name], [operations].[Name], [techcards].[Pochatok], [operations].[Duration]"
    psSQLRequest + "FROM [techcards] INNER JOIN"
    psSQLRequest + "  [operations] ON [operations].[ID] = [techcards].[ID_operations] INNER JOIN"
    psSQLRequest + "  [areas] ON [areas].[ID] = [techcards].[ID_areas] INNER JOIN"
    psSQLRequest + "  [cultures] ON [cultures].[ID] = [areas].[ID_culture] INNER JOIN"
    psSQLRequest + "  [gospodarstva] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva]"
    psSQLRequest + "Where [techcards].[Pochatok] >= " + Str(date) + " AND [techcards].[Pochatok] < " + Str(date + 21)
    psSQLRequest + " ORDER BY [techcards].[Pochatok]"
    szLabAx .s
    If DatabaseQuery(0, psSQLRequest) <> 0
      While NextDatabaseRow(0)
        ACount + 2
        ;Debug ACount 
        ReDim aData(ACount)
        szLabAx + GetDatabaseString(0, 0) +", " + GetDatabaseString(0, 1) + ", " + GetDatabaseString(0, 2) + "*"
        aData(ACount-2) = GetDatabaseLong(0, 3)
        aData(ACount-1) = GetDatabaseLong(0, 4)
      Wend    
        FinishDatabaseQuery(0)  
    EndIf  
    
    Caption.s = "Календарний графік виконання робіт з " + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, date - 134774)) + " до " + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, date + 21 - 134774)) 
    nRetVal = RMC_AddRegion(2048,5,5,-5,-5,"",#False) 
    nRetVal = RMC_AddCaption(2048,1,Caption,#ColorDefault,#ColorBlack,11,#True) 
    nRetVal = RMC_AddGrid(2048,1,#ColorPaleGoldenrod,#True,0,0,0,0,#RMC_BICOLOR_NONE) ;#ColorPaleGoldenrod
    ; the string labels for the data axis:
    szDataAx.s
    For i.l=0 To 21
      szDataAx + FormatDate("%dd.%mm", AddDate(0, #PB_Date_Day, date + i - 134774)) + "*"
    Next i
    
    RMC_AddDataAxis(2048,1,#RMC_DATAAXISBOTTOM,date,date+21,22,8,#ColorBlack,#ColorBlack,#RMC_LINESTYLESOLID,0,"","",szDataAx,#RMC_TEXTCENTER) 
    RMC_AddDataAxis(2048,1,#RMC_DATAAXISTOP,date,date+21,22,8,#ColorBlack,#ColorBlack,#RMC_LINESTYLESOLID,0,"","",szDataAx,#RMC_TEXTCENTER) 
    ; the labels for the label axis:149930
    RMC_AddLabelAxis(2048,1, szLabAx,1,ACount/2,#RMC_LABELAXISLEFT,8,#ColorBlack,#RMC_TEXTLEFT,#ColorBlack,#RMC_LINESTYLESOLID,"") 
    ; the legend:
    ;szTemp = "Schedule*Reality"
    ;RMC_AddLegend(2048,1,szTemp,#RMC_LEGEND_CUSTOM_UR,#ColorLightGoldenrodYellow,#RMC_LEGENDRECT,#ColorMediumBlue,8,#False) 
      
    RMC_AddBarSeries(2048,1,@aData(0), ACount,#RMC_FLOATINGBARGROUP,#RMC_BAR_FLAT_GRADIENT1,#False,#ColorOrangeRed,#True,1,#RMC_VLABEL_NONE,1,#RMC_HATCHBRUSH_OFF) 
    
    ; data for the second series, each bar has two data points, the start value and the length value:
    ;ReDim aData(7)
    ;aData(0) = date 
    ;aData(1) = 2 
    ;aData(2) = 0
    ;aData(3) = 0
    ;aData(4) = 0
    ;aData(5) = 0
    ;aData(6) = date + 5
    ;aData(7) = 5
    ;RMC_AddBarSeries(2048,1,@aData(0), 8,#RMC_FLOATINGBARGROUP,#RMC_BAR_HOVER,#False,#ColorBabyBlue,#True,1,#RMC_VLABEL_NONE,2,#RMC_HATCHBRUSH_OFF) 
    RMC_Draw(2048)
  EndIf
EndProcedure


Procedure Fixed()
  SetWindowTitle(#Window_0, #Program_Name + " - Виправлені помилки програми")
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  ButtonImageGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24, CatchImage(#icon3,?icon3))
    EditorGadget(#Editor_1,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#PB_Editor_ReadOnly)
    AddGadgetItem(#Editor_1, 1, "25 квітня 2012 р.")
    AddGadgetItem(#Editor_1, 2, "- Ставку дисконтування при визначенні питомих капіталовкладень встановлено на рівні 7%.")
    AddGadgetItem(#Editor_1, 3, "- Додано розрахунок функції мети в моделі (за мінімумом приведених витрат). Відображається в статусбарі.")
    AddGadgetItem(#Editor_1, 4, "- Виправлено помилку при записі результатів моделювання в файл.")
    AddGadgetItem(#Editor_1, 5, "- Виправлено помилку при роботі моделі лінійного програмування з ОП.")
    AddGadgetItem(#Editor_1, 6, "- Виправлено помилку додавання нового запису до таблиці.")
    AddGadgetItem(#Editor_1, 7, "")
    AddGadgetItem(#Editor_1, 8, "26 квітня 2012 р.")
    AddGadgetItem(#Editor_1, 9, "- Додано складання і експорт діаграми по графіку робіт (Плани -> Графік робіт).")
    AddGadgetItem(#Editor_1, 10, "")
    AddGadgetItem(#Editor_1, 11, "27 квітня 2012 р.")
    AddGadgetItem(#Editor_1, 12, "- Додано складання діаграми по графіку використання визначених енергомашин та с.-г. машин") 
    AddGadgetItem(#Editor_1, 12, "  (Модель -> Розрахувати.. -> Список енергомашин -> Подвійний клік на машині).")
    
  CloseGadgetList()
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#Editor_1)
      ResizeGadget(#Editor_1, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #ToolCloseButton      : FreeGadget(#Container_0): SetWindowTitle(#Window_0, #Program_Name)
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
  
  
EndProcedure

Procedure MainMenu(MainMenuItem.l)
  Select MainMenuItem
          Case #MenuCheck           ;
          Case #MenuAbout           :   MessageRequester("About AgroTech", " Copyright ©2012" + Chr(10) + " by Shamil Ibatullin" + Chr(10) + Chr(10) + "Version: 1.0")
          Case #MenuFixed           :   FreeGadget(#Container_0)  : Fixed()  
          Case #MenuClose           :   CloseDatabase(0)  : End
          Case #MenuGospodarstva    :   FreeGadget(#Container_0)  : Gospodarstva()  
          Case #MenuCulture         :   FreeGadget(#Container_0)  : Culture()            
          Case #MenuOperations      :   FreeGadget(#Container_0)  : Operations()
          Case #MenuTractors        :   FreeGadget(#Container_0)  : Tractors()
          Case #MenuMashinery       :   FreeGadget(#Container_0)  : Mashinery()
          Case #MenuAreas           :   FreeGadget(#Container_0)  : Areas()
          Case #MenuMTA             :   FreeGadget(#Container_0)  : MTA()
          Case #MenuTechCards       :   FreeGadget(#Container_0)  : TechCards()
          Case #MenuModel           :   FreeGadget(#Container_0)  : Model()
          Case #MenuGraf            :   FreeGadget(#Container_0)  : Grafik()  
  EndSelect          
EndProcedure

Procedure FormButtons()
  ButtonImageGadget(#ToolAddButton, 5, 3, 24, 24, CatchImage(#icon1,?icon1))
  ButtonImageGadget(#ToolDeleteButton, 32, 3, 24, 24, CatchImage(#icon2,?icon2))
  ButtonImageGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24, CatchImage(#icon3,?icon3))
  ButtonImageGadget(#ToolExpButton, 59, 3, 24, 24, CatchImage(#icon4,?icon4))
  GadgetToolTip(#ToolAddButton, "Додати")
  GadgetToolTip(#ToolDeleteButton, "Видалити")
  GadgetToolTip(#ToolExpButton, "Експорт")
EndProcedure


Procedure Gospodarstva()
  SetWindowTitle(#Window_0, #Program_Name + " - Довідник господарств")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину 
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  CloseGadgetList()
  
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Назва господарства" ,400,#TYPE_EDITTEXT)
        
  NewList row.Grid1() ;initiate grid rows list
    
  If DatabaseQuery(0,"SELECT * FROM [gospodarstva] ORDER BY [Name]") <> 0
    While NextDatabaseRow(0)
      AddElement(row())
      row()\col0 = GetDatabaseLong(0, 0)
      row()\col1 = GetDatabaseString(0, 1)
      AddGadgetGridItem(#grid,row())
    Wend
    FinishDatabaseQuery(0)  
  EndIf  
  
  BaseRequest.s = "SELECT count(*) FROM [gospodarstva]" 
  StatusUpdate (BaseRequest)
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#grid)
      ResizeGadget(#grid, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              psSQLRequest.s = "UPDATE [gospodarstva] SET "
              psSQLRequest + "Name='"+PeekS(lpData)+"'"
              psSQLRequest + " WHERE ID="+Str(row()\col0)
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              Else
                FinishDatabaseQuery(0) 
              EndIf  
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If DatabaseQuery(0, "SELECT max(ID) FROM [gospodarstva]") = 0
            MessageRequester("Помилка бази", DatabaseError())  
          Else
              NextDatabaseRow(0)
              MaxID.i =GetDatabaseLong(0, 0)
              NewID.s = Str(MaxID+1)
              FinishDatabaseQuery(0)
              psSQLRequest = "INSERT INTO [gospodarstva] "
              psSQLRequest + "(ID)"
              psSQLRequest + "VALUES ("
              psSQLRequest + "'"+NewID+"')"
          EndIf
          If DatabaseUpdate(0, psSQLRequest) = 0
              MessageRequester("Помилка запиту", DatabaseError())
          Else
            FinishDatabaseQuery(0)
            LastElement(row())
              AddElement(row())
              row()\col0=MaxID+1
              row()\col1=""
              AddGadgetGridItem(#grid,row()) 
          EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [areas]"
                psSQLRequest + "Where [areas].[ID_gospodarstva] = " + Str(row()\col0) 
                 If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                 Else
                   NextDatabaseRow(0)
                   If GetDatabaseLong(0, 0) = 0 
                     FinishDatabaseQuery(0)      
                      psSQLRequest = "DELETE FROM [gospodarstva] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Видаліть спочатку посіви по господарству.")
                   EndIf
                 EndIf
            EndIf 
          EndIf 
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
          
          
          
          
          
          
    ;psSQLRequest.s = "SELECT [gospodarstva].[Name], [cultures].[Name], [operations].[Name], [techcards].[Pochatok], [operations].[Duration]"
    ;psSQLRequest + "FROM [techcards] INNER JOIN"
    ;psSQLRequest + "  [operations] ON [operations].[ID] = [techcards].[ID_operations] INNER JOIN"
    ;psSQLRequest + "  [areas] ON [areas].[ID] = [techcards].[ID_areas] INNER JOIN"
    ;psSQLRequest + "  [cultures] ON [cultures].[ID] = [areas].[ID_culture] INNER JOIN"
    ;psSQLRequest + "  [gospodarstva] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva]"
    
    ;Dim  aData.l(0)
    ;If DatabaseQuery(0, psSQLRequest) <> 0
    ;  While NextDatabaseRow(0)
    ;    ACount + 2
    ;    Debug ACount 
    ;    ReDim aData(ACount)
    ;    aData(ACount-2) = GetDatabaseLong(0, 3)
    ;    aData(ACount-1) = GetDatabaseLong(0, 4)
    ;    Debug aData(ACount-1)
    ;        SetGadgetItemData(#Tree_0, CountGadgetItems(#Tree_0)-1, GetDatabaseLong(0, 0))
    ;  Wend    
    ;    FinishDatabaseQuery(0)  
    ;EndIf  
          
          
          
          
          
          
          
          ;IncludeFile "PureXLS_Test.pb"
          ;XLS_CreateFile("Довідник_господарства.xls")
          ;XLS_PrintGridLines(#False)
          ;XLS_SetFont("System", 10,#XLS_NoFormat)
          ;XLS_SetColumnWidth(0,0,50)
          ;FirstElement(row())
          ;i=0
          ;While NextElement(row())
          ;  XLS_WriteText(row()\col1,2 + i,0,#XLS_Font0,#XLS_LeftAlign,#XLS_CellNormal,0)
          ;  i + 1
          ;Wend
          ;XLS_CloseFile()
        Case #ToolCloseButton      : FreeGadget(#Container_0): SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure



Procedure Culture()
  SetWindowTitle(#Window_0, #Program_Name + " - Довідник сільськогосподарських культур")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  CloseGadgetList()
    
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Назва культури" ,400,#TYPE_EDITTEXT)
        
  NewList row.Grid1() ;initiate grid rows list
    
  If DatabaseQuery(0,"SELECT * FROM [cultures] ORDER BY [Name]") <> 0
    While NextDatabaseRow(0)
      AddElement(row())
      row()\col0 = GetDatabaseLong(0, 0)
      row()\col1 = GetDatabaseString(0, 1)
      AddGadgetGridItem(#grid,row())
    Wend
  EndIf  
  FinishDatabaseQuery(0)  
  BaseRequest.s = "SELECT count(*) FROM [cultures]" 
  StatusUpdate (BaseRequest)
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#grid)
      ResizeGadget(#grid, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              psSQLRequest.s = "UPDATE [cultures] SET "
              psSQLRequest + "Name='"+PeekS(lpData)+"'"
              psSQLRequest + " WHERE ID="+Str(row()\col0)
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              Else
                FinishDatabaseQuery(0) 
              EndIf  
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If DatabaseQuery(0, "SELECT max(ID) FROM [cultures]") = 0
            MessageRequester("Помилка бази", DatabaseError())  
          Else
              NextDatabaseRow(0)
              MaxID.i =GetDatabaseLong(0, 0)
              NewID.s = Str(MaxID+1)
              FinishDatabaseQuery(0)
              psSQLRequest = "INSERT INTO [cultures] "
              psSQLRequest + "(ID)"
              psSQLRequest + "VALUES ("
              psSQLRequest + "'"+NewID+"')"
          EndIf
          If DatabaseUpdate(0, psSQLRequest) = 0
              MessageRequester("Помилка запиту", DatabaseError())
          Else
            FinishDatabaseQuery(0)
            LastElement(row())
              AddElement(row())
              row()\col0=MaxID+1
              row()\col1=""
              AddGadgetGridItem(#grid,row()) 
          EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [MTA_culture]"
                psSQLRequest + "Where [MTA_culture].[ID_culture] = " + Str(row()\col0) 
                If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                Else
                   NextDatabaseRow(0)
                   CMcount.l = GetDatabaseLong(0, 0)
                   FinishDatabaseQuery(0)         
                EndIf
                psSQLRequest = "SELECT count (*) FROM [areas]"
                psSQLRequest + "Where [areas].[ID_culture] = " + Str(row()\col0) 
                If DatabaseQuery(0, psSQLRequest) = 0
                   MessageRequester("Помилка бази", DatabaseError())
                Else
                   NextDatabaseRow(0)
                   CAcount.l = GetDatabaseLong(0, 0)
                   FinishDatabaseQuery(0)      
                EndIf   
                   If CAcount = 0 And CMcount = 0 
                      psSQLRequest = "DELETE FROM [cultures] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Видаліть спочатку культуру з пов`язаних таблиць.")
                   EndIf
                 EndIf
          EndIf 
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure

Procedure Operations()
  SetWindowTitle(#Window_0, #Program_Name + " - Довідник операцій (робіт)")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  ColBeforEdit.l            ;колонка, в якій редагують клітину
  
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  CloseGadgetList()
      
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Назва операції" ,260,#TYPE_EDITTEXT)
    AddGridColumn(#grid,"Одиниця виміру" ,100,#TYPE_EDITTEXT, #GA_ALIGN_CENTER)
    AddGridColumn(#grid,"Тривалість, днів" ,100,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
        
  NewList row.Grid1() ;initiate grid rows list
    
  If DatabaseQuery(0,"SELECT * FROM [operations] ORDER BY [Name]") <> 0
    While NextDatabaseRow(0)
      AddElement(row())
      row()\col0 = GetDatabaseLong(0, 0)
      row()\col1 = GetDatabaseString(0, 1)
      row()\col2 = GetDatabaseString(0, 2)
      row()\col3 = GetDatabaseString(0, 3)
      AddGadgetGridItem(#grid,row())
    Wend
    FinishDatabaseQuery(0)  
  EndIf  
  BaseRequest.s = "SELECT count(*) FROM [operations]" 
  StatusUpdate (BaseRequest)
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#grid)
      ResizeGadget(#grid, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
              ColBeforEdit = GetGridCol(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              Select ColBeforEdit 
                  Case 1
                      psSQLRequest.s = "UPDATE [operations] SET "
                      psSQLRequest + "Name='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 2
                      psSQLRequest.s = "UPDATE [operations] SET "
                      psSQLRequest + "Odvim='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 3
                      psSQLRequest.s = "UPDATE [operations] SET "
                      psSQLRequest + "Duration='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
              EndSelect
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              Else
                FinishDatabaseQuery(0) 
              EndIf  
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If DatabaseQuery(0, "SELECT max(ID) FROM [operations]") = 0
            MessageRequester("Помилка бази", DatabaseError())  
          Else
              NextDatabaseRow(0)
              MaxID.i =GetDatabaseLong(0, 0)
              NewID.s = Str(MaxID+1)
              FinishDatabaseQuery(0)
              psSQLRequest = "INSERT INTO [operations] "
              psSQLRequest + "(ID)"
              psSQLRequest + "VALUES ("
              psSQLRequest + "'"+NewID+"')"
          EndIf
          If DatabaseUpdate(0, psSQLRequest) = 0
              MessageRequester("Помилка запиту", DatabaseError())
          Else
            FinishDatabaseQuery(0)
            LastElement(row())
              AddElement(row())
              row()\col0=MaxID+1
              AddGadgetGridItem(#grid,row()) 
          EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [techcards]"
                psSQLRequest + "Where [techcards].[ID_operations] = " + Str(row()\col0) 
                If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                Else
                   NextDatabaseRow(0)
                   OTcount.l = GetDatabaseLong(0, 0)
                   FinishDatabaseQuery(0)         
                EndIf
                psSQLRequest = "SELECT count (*) FROM [MTA]"
                psSQLRequest + "Where [MTA].[ID_operation] = " + Str(row()\col0) 
                If DatabaseQuery(0, psSQLRequest) = 0
                   MessageRequester("Помилка бази", DatabaseError())
                Else
                   NextDatabaseRow(0)
                   OMcount.l = GetDatabaseLong(0, 0)
                   FinishDatabaseQuery(0)      
                EndIf   
                   If OMcount = 0 And OTcount = 0 
                      psSQLRequest = "DELETE FROM [operations] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Видаліть спочатку оперцію з пов`язаних таблиць.")
                   EndIf
                 EndIf 
          EndIf 
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure

Procedure Tractors()
  SetWindowTitle(#Window_0, #Program_Name + " - Довідник енергетичних машин (тракторів, комбайнів)")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  ColBeforEdit.l            ;колонка, в якій редагують клітину
  
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  CloseGadgetList()
      
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Марка машини" ,300,#TYPE_EDITTEXT)
    AddGridColumn(#grid,"Балансова вартість, тис. грн." ,180,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Нормативна річна зайнятість, годин" ,200,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
        
  NewList row.Grid1() ;initiate grid rows list
    
  If DatabaseQuery(0,"SELECT * FROM [tractors] ORDER BY [Name]") <> 0
    While NextDatabaseRow(0)
      AddElement(row())
      row()\col0 = GetDatabaseLong(0, 0)
      row()\col1 = GetDatabaseString(0, 1)
      row()\col2 = GetDatabaseString(0, 2)
      row()\col3 = GetDatabaseString(0, 3)
      AddGadgetGridItem(#grid,row())
    Wend
    FinishDatabaseQuery(0)  
  EndIf  
  
  BaseRequest.s = "SELECT count(*) FROM [tractors]" 
  StatusUpdate (BaseRequest)
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#grid)
      ResizeGadget(#grid, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
              ColBeforEdit = GetGridCol(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              Select ColBeforEdit 
                  Case 1
                      psSQLRequest.s = "UPDATE [tractors] SET "
                      psSQLRequest + "Name='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 2
                      psSQLRequest.s = "UPDATE [tractors] SET "
                      psSQLRequest + "Price='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 3
                      psSQLRequest.s = "UPDATE [tractors] SET "
                      psSQLRequest + "Yearnorm='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
              EndSelect
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              Else
                FinishDatabaseQuery(0) 
              EndIf  
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If DatabaseQuery(0, "SELECT max(ID) FROM [tractors]") = 0
            MessageRequester("Помилка бази", DatabaseError())  
          Else
              NextDatabaseRow(0)
              MaxID.i =GetDatabaseLong(0, 0)
              NewID.s = Str(MaxID+1)
              FinishDatabaseQuery(0)
              psSQLRequest = "INSERT INTO [tractors] "
              psSQLRequest + "(ID)"
              psSQLRequest + "VALUES ("
              psSQLRequest + "'"+NewID+"')"
          EndIf
          If DatabaseUpdate(0, psSQLRequest) = 0
              MessageRequester("Помилка запиту", DatabaseError())
          Else
            FinishDatabaseQuery(0)
            LastElement(row())
              AddElement(row())
              row()\col0=MaxID+1
              AddGadgetGridItem(#grid,row()) 
          EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [MTA]"
                psSQLRequest + "Where [MTA].[ID_tractor] = " + Str(row()\col0) 
                 If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                 Else
                   NextDatabaseRow(0)
                   If GetDatabaseLong(0, 0) = 0 
                     FinishDatabaseQuery(0)      
                      psSQLRequest = "DELETE FROM [tractors] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Видаліть спочатку МТА з машиною.")
                  EndIf
                  EndIf
            EndIf 
          EndIf
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure

Procedure Mashinery()
  SetWindowTitle(#Window_0, #Program_Name + " - Довідник сільськогосподарських машин")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  ColBeforEdit.l            ;колонка, в якій редагують клітину
  
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  CloseGadgetList()
      
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Марка машини" ,300,#TYPE_EDITTEXT)
    AddGridColumn(#grid,"Балансова вартість, тис. грн." ,180,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Нормативна річна зайнятість, годин" ,200,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
        
  NewList row.Grid1() ;initiate grid rows list
    
  If DatabaseQuery(0,"SELECT * FROM [mashinery] ORDER BY [Name]") <> 0
    While NextDatabaseRow(0)
      AddElement(row())
      row()\col0 = GetDatabaseLong(0, 0)
      row()\col1 = GetDatabaseString(0, 1)
      row()\col2 = GetDatabaseString(0, 2)
      row()\col3 = GetDatabaseString(0, 3)
      AddGadgetGridItem(#grid,row())
    Wend
    FinishDatabaseQuery(0)  
  EndIf  
  
  BaseRequest.s = "SELECT count(*) FROM [mashinery]" 
  StatusUpdate (BaseRequest)
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#grid)
      ResizeGadget(#grid, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
              ColBeforEdit = GetGridCol(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              Select ColBeforEdit 
                  Case 1
                      psSQLRequest.s = "UPDATE [mashinery] SET "
                      psSQLRequest + "Name='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 2
                      psSQLRequest.s = "UPDATE [mashinery] SET "
                      psSQLRequest + "Price='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 3
                      psSQLRequest.s = "UPDATE [mashinery] SET "
                      psSQLRequest + "Yearnorm='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
              EndSelect
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              Else
                FinishDatabaseQuery(0) 
              EndIf  
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If DatabaseQuery(0, "SELECT max(ID) FROM [mashinery]") = 0
            MessageRequester("Помилка бази", DatabaseError())  
          Else
              NextDatabaseRow(0)
              MaxID.i =GetDatabaseLong(0, 0)
              NewID.s = Str(MaxID+1)
              FinishDatabaseQuery(0)
              psSQLRequest = "INSERT INTO [mashinery] "
              psSQLRequest + "(ID)"
              psSQLRequest + "VALUES ("
              psSQLRequest + "'"+NewID+"')"
          EndIf
          If DatabaseUpdate(0, psSQLRequest) = 0
              MessageRequester("Помилка запиту", DatabaseError())
          Else
            FinishDatabaseQuery(0)
            LastElement(row())
              AddElement(row())
              row()\col0=MaxID+1
              AddGadgetGridItem(#grid,row()) 
          EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [MTA]"
                psSQLRequest + "Where [MTA].[ID_mashinery] = " + Str(row()\col0) 
                 If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                 Else
                   NextDatabaseRow(0)
                   If GetDatabaseLong(0, 0) = 0 
                     FinishDatabaseQuery(0)      
                      psSQLRequest = "DELETE FROM [mashinery] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Видаліть спочатку МТА з машиною.")
                  EndIf
                 EndIf
            EndIf 
          EndIf 
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure

Procedure Areas()
  SetWindowTitle(#Window_0, #Program_Name + " - План посівних площ")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  ColBeforEdit.l            ;колонка, в якій редагують клітину
  
  StatusUpdate ("")
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,#Null,#Null,#Null, #Null,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  ListIconGadget(#Listicon_1, #Null, #Null, #Null, #Null, "Назва господарства",195, #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  SplitterGadget(#Splitter_1, 5, 30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35, #Listicon_1, #grid, #PB_Splitter_Vertical | #PB_Splitter_FirstFixed)
  SetGadgetState(#Splitter_1, 200)
  CloseGadgetList()
  
    ; Заповнення списку господарств
    If DatabaseQuery(0, "SELECT * FROM [gospodarstva] ORDER BY [Name]") <> 0
      While NextDatabaseRow(0)
        AddGadgetItem(#Listicon_1, CountGadgetItems(#Listicon_1), GetDatabaseString(0, 1))
        SetGadgetItemData(#Listicon_1, CountGadgetItems(#Listicon_1)-1, GetDatabaseLong(0, 0))
      Wend
    Else
      MessageRequester("Помилка бази", DatabaseError())
    EndIf
    FinishDatabaseQuery(0)
    
    ; Формування колонок грида посівів
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"ID госп",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Культура" ,190,#TYPE_COMBOBOX)
    AddGridColumn(#grid,"Урожайність, т/га" ,110,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Площа поісву, га" ,100,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Середня відстань перевезень, км" ,0,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    
    ; Заповнення комбо культури
    Structure Culture
      idcol.l     ; код культури
      namecol.s   ; назва культури, що виводиться в грид
    EndStructure 
    
    If DatabaseQuery(0,"SELECT count(*) FROM [cultures]")<>0
      NextDatabaseRow(0)
      Cultcount.l =GetDatabaseLong(0, 0)
    EndIf
    FinishDatabaseQuery(0)  
    
    Dim cultcomb.Culture(Cultcount)
    i.l=0
    If DatabaseQuery(0,"SELECT * FROM [cultures] ORDER BY [Name]") <> 0
      While NextDatabaseRow(0)      
        cultcomb(i)\idcol = GetDatabaseLong(0, 0)     
        cultcomb(i)\namecol = GetDatabaseString(0, 1)
        AddGridComboString(#grid,2,cultcomb(i)\namecol)
        i=i+1
      Wend
    EndIf
    FinishDatabaseQuery(0)
    
    ; Оголошення структури для гриду площ посівів
    Structure GridArea
      col0.l
      col1.l
      col2.l
      col3.s
      col4.s
      col5.s
    EndStructure 
  
    NewList row.GridArea() ;initiate grid rows list 
    
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#Splitter_1)
      ResizeGadget(#Splitter_1, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #Listicon_1            ; Заповнення гриду культури та площі при виборі господарства
          ClearList(row())
          ResetContent(#grid)
          psSQLRequest.s = "SELECT [areas].*, [cultures].[Name] "
          psSQLRequest + "FROM [areas] INNER JOIN"
          psSQLRequest + " [gospodarstva] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva] LEFT JOIN"
          psSQLRequest + " [cultures] ON [areas].[ID_culture] = [cultures].[ID]"
          psSQLRequest + " Where [gospodarstva].[ID] = "+Str(GetGadgetItemData(#Listicon_1,GetGadgetState(#Listicon_1)))
          psSQLRequest + " ORDER BY [cultures].[Name]"
          If DatabaseQuery(0,psSQLRequest) <> 0
            While NextDatabaseRow(0)
              AddElement(row())                       ; Заповнення динамічного списку
              row()\col0 = GetDatabaseLong(0, 0)      ; Код посіву
              row()\col1 = GetDatabaseLong(0, 1)      ; Код господарства
              i = 0
              While cultcomb(i)\idcol <> GetDatabaseLong(0, 2) And i< Cultcount
                i=i+1
              Wend 
              row()\col2 = i                          ; Назва культури
              row()\col3 = GetDatabaseString(0, 3)    ; Урожайність
              row()\col4 = GetDatabaseString(0, 4)    ; Площа посіву
              row()\col5 = GetDatabaseString(0, 5)    ; Відстань перевезень
              AddGadgetGridItem(#grid,row())
            Wend
          EndIf 
          FinishDatabaseQuery(0) 
          BaseRequest.s = "SELECT count(*) FROM [areas] INNER JOIN" 
          BaseRequest + " [gospodarstva] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva] LEFT JOIN"
          BaseRequest + " [cultures] ON [areas].[ID_culture] = [cultures].[ID]"
          BaseRequest + " Where [gospodarstva].[ID] = "+Str(GetGadgetItemData(#Listicon_1,GetGadgetState(#Listicon_1)))
          StatusUpdate (BaseRequest)
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
              ColBeforEdit = GetGridCol(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              Select ColBeforEdit 
                Case 2
                      psSQLRequest.s = "UPDATE [areas] SET "
                      psSQLRequest + "ID_culture='"+ Str(cultcomb(PeekL(lpData))\idcol) +"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 3
                      psSQLRequest.s = "UPDATE [areas] SET "
                      psSQLRequest + "Urogainist='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 4
                      psSQLRequest.s = "UPDATE [areas] SET "
                      psSQLRequest + "Area='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                  Case 5
                      psSQLRequest.s = "UPDATE [areas] SET "
                      psSQLRequest + "Av_distance='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
              EndSelect
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              Else
                FinishDatabaseQuery(0) 
              EndIf  
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If GetGadgetState(#Listicon_1)>-1
              If DatabaseQuery(0, "SELECT max(ID) FROM [areas]") = 0
                MessageRequester("Помилка бази", DatabaseError())  
              Else
                  NextDatabaseRow(0)
                  MaxID.i =GetDatabaseLong(0, 0)
                  NewID.s = Str(MaxID+1)
                  FinishDatabaseQuery(0)
                  psSQLRequest = "INSERT INTO [areas] "
                  psSQLRequest + "(ID, ID_gospodarstva)"
                  psSQLRequest + "VALUES ("
                  psSQLRequest + "'"+NewID+"',"
                  psSQLRequest + "'"+Str(GetGadgetItemData(#Listicon_1, GetGadgetState(#Listicon_1)))+"')"
                EndIf
                If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка запиту", DatabaseError())
                Else
                  FinishDatabaseQuery(0)
                  LastElement(row())
                  AddElement(row())
                  row()\col0=MaxID+1
                  row()\col2=-1
                  AddGadgetGridItem(#grid,row()) 
                  rowcount.l = GetRowCount(#grid)
                  SetCurRow(#grid,rowcount-1) ; встати на нову клітинку
                EndIf
            EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [techcards]"
                psSQLRequest + "Where [techcards].[ID_areas] = " + Str(row()\col0) 
                 If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                 Else
                   NextDatabaseRow(0)
                   If GetDatabaseLong(0, 0) = 0 
                     FinishDatabaseQuery(0)      
                      psSQLRequest = "DELETE FROM [areas] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Видаліть спочатку робочий процес з посівом.")
                  EndIf
                EndIf
                EndIf
          EndIf 
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
    EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure
           
Procedure MTA()
  SetWindowTitle(#Window_0, #Program_Name + " - Комплектування машино-тракторних агрегатів")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  ColBeforEdit.l            ;колонка, в якій редагують клітину
  
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,5,30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  CloseGadgetList()
  
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Операція" ,220,#TYPE_COMBOBOX)
    AddGridColumn(#grid,"Енергомашина" ,150,#TYPE_COMBOBOX)
    AddGridColumn(#grid,"С.-г. машина" ,200,#TYPE_COMBOBOX)
    AddGridColumn(#grid,"Денна норма виробітку" ,140,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Собівартість, грн./га", 120,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Культури",320,#TYPE_BUTTON)
        
    ; Заповнення комбо операцій
    Structure Operations
      idcol.l     ; код операції
      namecol.s   ; назва операції, що виводиться в грид
    EndStructure 
    If DatabaseQuery(0,"SELECT count(*) FROM [operations]")<>0
      NextDatabaseRow(0)
      Opercount.l =GetDatabaseLong(0, 0)
    EndIf
    FinishDatabaseQuery(0)  
    Dim opercomb.Operations(Opercount)
    i.l=0
    If DatabaseQuery(0,"SELECT * FROM [operations] ORDER BY [Name]") <> 0
      While NextDatabaseRow(0)      
        opercomb(i)\idcol = GetDatabaseLong(0, 0)     
        opercomb(i)\namecol = GetDatabaseString(0, 1)
        AddGridComboString(#grid,1,opercomb(i)\namecol)
        i=i+1
      Wend
    EndIf
    FinishDatabaseQuery(0)
    
    ; Заповнення комбо тракторів
    Structure Tractors
      idcol.l     ; код операції
      namecol.s   ; назва операції, що виводиться в грид
    EndStructure 
    If DatabaseQuery(0,"SELECT count(*) FROM [tractors]")<>0
      NextDatabaseRow(0)
      Tractcount.l =GetDatabaseLong(0, 0)
    EndIf
    FinishDatabaseQuery(0)  
    Dim tractcomb.Tractors(Tractcount)
    i.l=0
    If DatabaseQuery(0,"SELECT * FROM [tractors] ORDER BY [Name]") <> 0
      While NextDatabaseRow(0)      
        tractcomb(i)\idcol = GetDatabaseLong(0, 0)     
        tractcomb(i)\namecol = GetDatabaseString(0, 1)
        AddGridComboString(#grid,2,tractcomb(i)\namecol)
        i=i+1
      Wend
    EndIf
    FinishDatabaseQuery(0)
    
    ; Заповнення комбо с.-г. машин
    Structure Mashinery
      idcol.l     ; код операції
      namecol.s   ; назва операції, що виводиться в грид
    EndStructure 
    If DatabaseQuery(0,"SELECT count(*) FROM [mashinery]")<>0
      NextDatabaseRow(0)
      Mashcount.l =GetDatabaseLong(0, 0)
    EndIf
    FinishDatabaseQuery(0)  
    Dim mashcomb.Mashinery(Mashcount)
    i.l=0
    If DatabaseQuery(0,"SELECT * FROM [mashinery] ORDER BY [Name]") <> 0
      While NextDatabaseRow(0)      
        mashcomb(i)\idcol = GetDatabaseLong(0, 0)     
        mashcomb(i)\namecol = GetDatabaseString(0, 1)
        AddGridComboString(#grid,3,mashcomb(i)\namecol)
        i=i+1
      Wend
    EndIf
    FinishDatabaseQuery(0)
    
    ; Оголошення структури для гриду агрегатів
    Structure GridMTA
      col0.l
      col1.l
      col2.l
      col3.l
      col4.s
      col5.s
      col6.s
    EndStructure 
  
    NewList row.GridMTA() ;initiate grid rows list 
    
    ; Зібрати інформацію про культури, які привязані до агрегатів
    ProcedureString.s
    If DatabaseQuery(0, "Select max(ID) FROM [MTA]")<>0
      NextDatabaseRow(0)
        MTAcount.l = GetDatabaseLong(0,0)
    EndIf
    FinishDatabaseQuery(0)
    
    If MTAcount>0
      Dim MTA_culture.s(MTAcount+1)
      i.l=0
      While i <= MTAcount  
        psSQLRequest.s = "SELECT [MTA_culture].*, [cultures].[Name]"
        psSQLRequest+ "   FROM [MTA_culture] INNER JOIN"
        psSQLRequest+ "   [cultures] ON [cultures].[ID] = [MTA_culture].[ID_culture]"
        psSQLRequest + "  Where [ID_MTA] = "+ "'"+Str(i)+ "'"
        psSQLRequest + "  ORDER BY [cultures].[Name]"  
        If DatabaseQuery(0, psSQLRequest) <>0
          While NextDatabaseRow(0)
            MTA_culture(i) = MTA_culture(i) + GetDatabaseString(0, 3) + ", "    
          Wend
        EndIf 
        FinishDatabaseQuery(0)
        i = i + 1
      Wend  
    EndIf
        
    ; Заповнення гриду даними
          psSQLRequest.s = "SELECT [MTA].*, [operations].[Name], [tractors].[Name], [mashinery].[Name]"
          psSQLRequest + "FROM [MTA] LEFT JOIN"
          psSQLRequest + " [operations] ON [operations].[ID] = [MTA].[ID_operation] LEFT JOIN"
          psSQLRequest + " [tractors] ON [tractors].[ID] = [MTA].[ID_tractor] LEFT JOIN"
          psSQLRequest + " [mashinery] ON [mashinery].[ID] = [MTA].[ID_mashinery]"
          psSQLRequest + " ORDER BY [operations].[Name], [tractors].[Name], [mashinery].[Name]"   
            
    If DatabaseQuery(0,psSQLRequest) <> 0
    While NextDatabaseRow(0)
      AddElement(row())
      row()\col0 = GetDatabaseLong(0, 0)
      i = 0
      While opercomb(i)\idcol <> GetDatabaseLong(0, 1) And i< Opercount
        i=i+1
      Wend 
      row()\col1 = i                        ; Назва операції
      i = 0
      While tractcomb(i)\idcol <> GetDatabaseLong(0, 2) And i< Tractcount
        i=i+1
      Wend 
      row()\col2 = i                        ; Назва трактора
      i = 0
      While mashcomb(i)\idcol <> GetDatabaseLong(0, 3) And i< Mashcount
        i=i+1
      Wend 
      row()\col3 = i                        ; Назва с.-г. машини
      row()\col4 = GetDatabaseString(0, 4)
      row()\col5 = GetDatabaseString(0, 5)
      row()\col6 = MTA_culture(GetDatabaseLong(0, 0))
      AddGadgetGridItem(#grid,row())
    Wend
    FinishDatabaseQuery(0)  
  EndIf  
  button_chek.l = 0 ; тригер для вибору культур
  
  BaseRequest.s = "SELECT count(*) FROM [MTA]" 
  StatusUpdate (BaseRequest)
  
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0) 
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#grid)
      ResizeGadget(#grid, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_ButtonClick  
              EnableWindow_(WindowID(#Window_0),#False) 
              OpenWindow(#Window_1, 500,300,250,380,"Виберіть культури для агрегату",#PB_Window_ScreenCentered | #PB_Window_NoGadgets,WindowID(#Window_0))
              OldGadgetList = UseGadgetList(WindowID(#Window_1)) ; Create GadgetList and store old GadgetList
              ListIconGadget(#Listicon_1,  0, 0, 250, 340, "Назва культури", 240, #PB_ListIcon_CheckBoxes)  ; ListIcon with checkbox  
              If DatabaseQuery(0,"SELECT * FROM [cultures] ORDER BY [Name]") <> 0
                While NextDatabaseRow(0)
                  AddGadgetItem(#Listicon_1, -1, GetDatabaseString(0,1))
                  SetGadgetItemData(#Listicon_1, CountGadgetItems(#Listicon_1)-1, GetDatabaseLong(0, 0))
                Wend
              EndIf  
              FinishDatabaseQuery(0)  
              
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              
              For i = 0 To CountGadgetItems(#Listicon_1)-1
                psSQLRequest.s = "SELECT * FROM [MTA_culture]"
                psSQLRequest + "Where [MTA_culture].[ID_MTA] = " + Str(row()\col0) +" And [MTA_culture].[ID_culture]="+Str(GetGadgetItemData(#Listicon_1,i))   
                If DatabaseQuery(0,psSQLRequest) <> 0
                  If NextDatabaseRow(0)
                    SetGadgetItemState(#Listicon_1,i,2) 
                  EndIf  
                EndIf
              Next i
              
              ButtonGadget(#Button_0, 135,345,50,26,"Так")
              ButtonGadget(#Button_1, 190,345,50,26,"Відміна")
              ButtonGadget(#Button_2, 10,345,90,26,"Виділити/зняти")
              
              UseGadgetList(OldGadgetList)          
              
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
              ColBeforEdit = GetGridCol(#grid)
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              If ColBeforEdit <> 6
                Select ColBeforEdit 
                    Case 1
                      If PeekL(lpData) <> -1
                      psSQLRequest.s = "UPDATE [MTA] SET "
                      psSQLRequest + "ID_operation='"+ Str(opercomb(PeekL(lpData))\idcol) +"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                      EndIf
                    Case 2
                      If PeekL(lpData) <> -1
                      psSQLRequest.s = "UPDATE [MTA] SET "
                      psSQLRequest + "ID_tractor='"+ Str(tractcomb(PeekL(lpData))\idcol) +"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                      EndIf
                    Case 3
                      If PeekL(lpData) <> -1
                      psSQLRequest.s = "UPDATE [MTA] SET "
                      psSQLRequest + "ID_mashinery='"+ Str(mashcomb(PeekL(lpData))\idcol) +"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                      EndIf
                    Case 4
                      psSQLRequest.s = "UPDATE [MTA] SET "
                      psSQLRequest + "Norma='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                    Case 5
                      psSQLRequest.s = "UPDATE [MTA] SET "
                      psSQLRequest + "Cost='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                EndSelect
                If DatabaseUpdate(0, psSQLRequest) = 0
                    MessageRequester("Помилка1 збереження", DatabaseError())
                EndIf
                FinishDatabaseQuery(0) 
              EndIf
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If DatabaseQuery(0, "SELECT max(ID) FROM [MTA]") = 0
            MessageRequester("Помилка бази", DatabaseError())  
          Else
              NextDatabaseRow(0)
              MaxID.i =GetDatabaseLong(0, 0)
              NewID.s = Str(MaxID+1)
              FinishDatabaseQuery(0)
              psSQLRequest = "INSERT INTO [MTA] "
              psSQLRequest + "(ID)"
              psSQLRequest + "VALUES ("
              psSQLRequest + "'"+NewID+"')"
          EndIf
          If DatabaseUpdate(0, psSQLRequest) = 0
              MessageRequester("Помилка запиту", DatabaseError())
          Else
              FinishDatabaseQuery(0)
              LastElement(row())
              AddElement(row())
              row()\col0=MaxID+1
              row()\col1=-1
              row()\col2=-1
              row()\col3=-1
              AddGadgetGridItem(#grid,row())
              rowcount.l = GetRowCount(#grid)
              SetCurRow(#grid,rowcount-1) ; встати на нову клітинку
          EndIf
          StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "SELECT count (*) FROM [MTA_culture]"
                psSQLRequest + "Where [MTA_culture].[ID_MTA] = " + Str(row()\col0) 
                 If DatabaseQuery(0, psSQLRequest) = 0
                    MessageRequester("Помилка бази", DatabaseError())
                 Else
                   NextDatabaseRow(0)
                   If GetDatabaseLong(0, 0) = 0 
                     FinishDatabaseQuery(0)      
                      psSQLRequest = "DELETE FROM [MTA] WHERE id="+ Str(row()\col0)
                       If DatabaseUpdate(0, psSQLRequest) = 0
                          MessageRequester("Помилка видалення", DatabaseError())
                       Else
                         ; Удаляем выбранный элемент из списка
                         DeleteRow(#grid, RowDelete)
                         DeleteElement(row())
                         Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                       EndIf                   
                   Else
                    MessageRequester("Увага!", "Неможливо видалити." + Chr(10) + "Спочатку треба зняти зв`язок з культурою.")
                  EndIf
                EndIf
                EndIf
          EndIf
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #Button_0                    ; Кнопка Так при виборі культур на агрегаті
          FirstElement(row())
          For i=1 To RowBeforEdit
            NextElement(row())
          Next i
          psSQLRequest.s = "DELETE FROM [MTA_culture] WHERE [ID_MTA]="+ Str(row()\col0)
          If DatabaseUpdate(0, psSQLRequest) = 0
            MessageRequester("Помилка видалення", DatabaseError())
          EndIf
          Cell_write.s=""
          
          For i = 0 To CountGadgetItems(#Listicon_1)-1
            If GetGadgetItemState(#Listicon_1, i) > 1
              If DatabaseQuery(0, "SELECT max(ID) FROM [MTA_culture]") = 0
                MessageRequester("Помилка бази", DatabaseError())  
              Else
                Cell_write+GetGadgetItemText(#Listicon_1,i)+", "   
                NextDatabaseRow(0)
                MaxID.i =GetDatabaseLong(0, 0)
                NewID.s = Str(MaxID+1)
                FinishDatabaseQuery(0)
                psSQLRequest.s = "INSERT INTO [MTA_culture] "
                psSQLRequest + "(ID,ID_MTA,ID_culture)"
                psSQLRequest + "VALUES ("
                psSQLRequest + "'"+NewID+"',"
                psSQLRequest + "'"+Str(row()\col0)+"',"
                psSQLRequest + "'"+Str(GetGadgetItemData(#Listicon_1,i))+"')"
              EndIf
              If DatabaseUpdate(0, psSQLRequest) = 0
                MessageRequester("Помилка бази", DatabaseError())
              EndIf
              ;psSQLRequest=""
              FinishDatabaseQuery(0)
           EndIf 
          Next i
          lpData = AllocateMemory(500) 
          PokeS(lpData, Cell_write)
          SetCellData(#grid, cell, lpData)
          CloseWindow(#Window_1)
          EnableWindow_(WindowID(#Window_0),#True) 
          
        Case #Button_1                  ; Кнопка Відміна при виборі агрегата  
          CloseWindow(#Window_1)  
          EnableWindow_(WindowID(#Window_0),#True) 
        Case #Button_2     ; Кнопка Виділити/зняти  
          If button_chek = 0
            For i = 0 To CountGadgetItems(#Listicon_1)-1
              SetGadgetItemState(#Listicon_1, i, 2)
            Next i
            button_chek = 1
          Else
            For i = 0 To CountGadgetItems(#Listicon_1)-1
              SetGadgetItemState(#Listicon_1, i, 0)
            Next i
            button_chek = 0
          EndIf
        
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow 
  
EndProcedure

Procedure TechCards()
  ;UseGadgetList(WindowID(#Window_0))
  SetWindowTitle(#Window_0, #Program_Name + " - Технологічні карти вирощування культур")
  cell.l                    ;клітинка, яку редагують
  RowBeforEdit.l            ;рядок, в якому редагують клітину
  ColBeforEdit.l            ;колонка, в якій редагують клітину
  StatusUpdate ("")
  
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  FormButtons()
  GridGadget(#grid,#Null,#Null,#Null, #Null,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES)
  TreeGadget(#Tree_0, #Null, #Null, #Null, #Null, #PB_Tree_AlwaysShowSelection)
  SplitterGadget(#Splitter_1, 5, 30,WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35, #Tree_0, #grid, #PB_Splitter_Vertical | #PB_Splitter_FirstFixed)
  SetGadgetState(#Splitter_1, 310)
  CloseGadgetList()
  
    ; Заповнення дерева господарств і культур
    Gosp.s = ""
      psSQLRequest.s = "Select [areas].[ID], [gospodarstva].[Name], [cultures].[Name],"
      psSQLRequest + "[areas].[Urogainist], [areas].[Area]"
      psSQLRequest + "FROM [gospodarstva] INNER JOIN"
      psSQLRequest + "[areas] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva] INNER JOIN"
      psSQLRequest + "[cultures] ON [cultures].[ID] = [areas].[ID_culture]"
      psSQLRequest + "ORDER BY [gospodarstva].[Name], [cultures].[Name]"
  
    If DatabaseQuery(0, psSQLRequest) <> 0
        While NextDatabaseRow(0)
          If GetDatabaseString(0, 1) <> Gosp 
            Gosp = GetDatabaseString(0, 1)
            AddGadgetItem(#Tree_0, -1, GetDatabaseString(0, 1),0,0)
            SetGadgetItemData(#Tree_0, CountGadgetItems(#Tree_0)-1, GetDatabaseLong(0, 0))
          EndIf   
          AddGadgetItem(#Tree_0, -1, GetDatabaseString(0, 2)+" - "+GetDatabaseString(0, 3)+" т/га - "+GetDatabaseString(0, 4)+" га", 0, 1)
          SetGadgetItemData(#Tree_0, CountGadgetItems(#Tree_0)-1, GetDatabaseLong(0, 0))
        Wend         
    EndIf  

    FinishDatabaseQuery(0)  
    
    ; Expand all nodes for a nicer view
      For i = 0 To CountGadgetItems(#Tree_0) - 1
        SetGadgetItemState(#Tree_0, i, #PB_Tree_Expanded)
      Next i
           
    ; Формування колонок грида посівів
    AddGridColumn(#grid,"ID",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"ID_areas",0,#TYPE_EDITLONG)
    AddGridColumn(#grid,"Операція",220,#TYPE_COMBOBOX)
    AddGridColumn(#grid,"Обсяг робіт на 100 га" ,120,#TYPE_EDITTEXT, #GA_ALIGN_RIGHT)
    AddGridColumn(#grid,"Початок" ,80,#TYPE_DATE, #GA_ALIGN_RIGHT)
    
    ; Заповнення комбо операцій
    Structure Operation
      idcol.l     ; код операції
      namecol.s   ; назва операції, що виводиться в грид
    EndStructure 
      
    If DatabaseQuery(0,"SELECT count(*) FROM [operations]")<>0
      NextDatabaseRow(0)
      Opercount.l =GetDatabaseLong(0, 0)
    EndIf
    FinishDatabaseQuery(0)  
   
    Dim opercomb.Operation(Opercount)
    i=0
    If DatabaseQuery(0,"SELECT * FROM [operations] ORDER BY [Name]") <> 0
      While NextDatabaseRow(0)      
        opercomb(i)\idcol = GetDatabaseLong(0, 0)     
        opercomb(i)\namecol = GetDatabaseString(0, 1)
        AddGridComboString(#grid,2,opercomb(i)\namecol)
        i=i+1
      Wend
    EndIf
    FinishDatabaseQuery(0)
    
    ; Оголошення структури для гриду техоперацій
    Structure GridTechCards
      col0.l
      col1.l
      col2.l
      col3.s
      col4.l
    EndStructure 
  
    NewList row.GridTechCards() ;initiate grid rows list 
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
        End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf  
    If IsGadget(#Splitter_1)
      ResizeGadget(#Splitter_1, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #Tree_0            ; Заповнення гриду культури та площі при виборі господарства-культури
          ClearList(row())
          ResetContent(#grid)
          
          ; Треба дізнатись код культури, для якої формуємо грид та комбо операцій
          psSQLRequest.s = "Select * FROM [areas] Where [ID] ="
          psSQLRequest + Str(GetGadgetItemData(#Tree_0,GetGadgetState(#Tree_0)))
          If DatabaseQuery(0,psSQLRequest) <> 0
            NextDatabaseRow(0)      
            CultID.l = GetDatabaseLong(0, 2)     
          EndIf
          FinishDatabaseQuery(0)
                        
          ; Заповнення комбо операцій, саме тих операцій, для яких є агрегати по цій культурі!!!
          ClearGridComboString(#grid,2)
          
          psSQLRequest.s = "Select count (*) FROM [operations] INNER JOIN"
          psSQLRequest + " [MTA] ON [operations].[ID] = [MTA].[ID_operation] INNER JOIN"
          psSQLRequest + " [MTA_culture] ON [MTA].[ID] = [MTA_culture].[ID_MTA] INNER JOIN"
          psSQLRequest + " [cultures] ON [cultures].[ID] = [MTA_culture].[ID_culture]"
          psSQLRequest + " Where [cultures].[ID] = " + Str(CultID)
          If DatabaseQuery(0,psSQLRequest)<>0
            NextDatabaseRow(0)
            Opercount.l =GetDatabaseLong(0, 0)
          EndIf
          FinishDatabaseQuery(0)  
          
          ReDim opercomb.Operation(Opercount)
          i=0
          psSQLRequest.s = "Select [operations].[ID], [operations].[Name], [cultures].[ID] FROM [operations] INNER JOIN"
          psSQLRequest + " [MTA] ON [operations].[ID] = [MTA].[ID_operation] INNER JOIN"
          psSQLRequest + " [MTA_culture] ON [MTA].[ID] = [MTA_culture].[ID_MTA] INNER JOIN"
          psSQLRequest + " [cultures] ON [cultures].[ID] = [MTA_culture].[ID_culture]"
          psSQLRequest + " GROUP BY [operations].[ID], [operations].[Name], [cultures].[ID]"
          psSQLRequest + " HAVING [cultures].[ID] = " + Str(CultID)
          psSQLRequest + " ORDER BY [operations].[Name]"
          If DatabaseQuery(0,psSQLRequest ) <> 0
            While NextDatabaseRow(0)      
              opercomb(i)\idcol = GetDatabaseLong(0, 0)     
              opercomb(i)\namecol = GetDatabaseString(0, 1)
              AddGridComboString(#grid,2,opercomb(i)\namecol)
              i=i+1
            Wend
          EndIf
          FinishDatabaseQuery(0)
          
          psSQLRequest.s = "SELECT * "
          psSQLRequest + "FROM [techcards]"
          psSQLRequest + " Where [ID_areas] = "+Str(GetGadgetItemData(#Tree_0,GetGadgetState(#Tree_0)))
          psSQLRequest + " ORDER BY [Pochatok]"
          If DatabaseQuery(0,psSQLRequest) <> 0
            While NextDatabaseRow(0)
              AddElement(row())                       ; Заповнення динамічного списку
              row()\col0 = GetDatabaseLong(0, 0)      ; Код техоперації
              row()\col1 = GetDatabaseLong(0, 1)      ; Код посіву
              i = 0
              While opercomb(i)\idcol <> GetDatabaseLong(0, 2) And i< Opercount
                i=i+1
              Wend 
              row()\col2 = i                          ; Назва операції
              row()\col3 = GetDatabaseString(0, 3)    ; Обсяг робіт на 100 га
              row()\col4 = GetDatabaseLong(0, 4)      ; Початок операції
              AddGadgetGridItem(#grid,row())
            Wend
          EndIf 
          FinishDatabaseQuery(0)  
          BaseRequest.s = "SELECT count(*) FROM [techcards]" 
          BaseRequest + " Where [ID_areas] = "+Str(GetGadgetItemData(#Tree_0,GetGadgetState(#Tree_0)))
          StatusUpdate (BaseRequest)
          
        Case #grid
          Select EventType()
            Case #PB_EventType_Grid_BeforeEdit      ; запис даних про клітину, яку почали редагувати
              cell= GetCurCell(#grid)
              RowBeforEdit = GetGridRow(#grid)
              ColBeforEdit = GetGridCol(#grid) 
            Case #PB_EventType_Grid_AfterUpdate     ; збереження (оновлення) змінених даних у базі
              lpData = AllocateMemory(500) 
              GetCellData(#grid, cell, lpData)
              FirstElement(row())
              For i=1 To RowBeforEdit
                NextElement(row())
              Next i
              Select ColBeforEdit 
                Case 2
                      psSQLRequest.s = "UPDATE [techcards] SET "
                      psSQLRequest + "ID_operations='"+ Str(opercomb(PeekL(lpData))\idcol) +"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                Case 3
                      psSQLRequest.s = "UPDATE [techcards] SET "
                      psSQLRequest + "Obsyag='"+PeekS(lpData)+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
                Case 4
                      psSQLRequest.s = "UPDATE [techcards] SET "
                      psSQLRequest + "Pochatok='"+Str(PeekL(lpData))+"'"
                      psSQLRequest + " WHERE ID="+Str(row()\col0)
               EndSelect
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка збереження", DatabaseError())
              EndIf  
              FinishDatabaseQuery(0) 
              FreeMemory(lpData)
              StatusUpdate (BaseRequest)
          EndSelect
        Case #ToolAddButton                         ; додати новий запис
          If GetGadgetState(#Tree_0)>-1
              If DatabaseQuery(0, "SELECT max(ID) FROM [techcards]") = 0
                MessageRequester("Помилка бази", DatabaseError())  
              Else
                  NextDatabaseRow(0)
                  MaxID.i =GetDatabaseLong(0, 0)
                  NewID.s = Str(MaxID+1)
                  FinishDatabaseQuery(0)
                  psSQLRequest = "INSERT INTO [techcards] "
                  psSQLRequest + "(ID, ID_areas, Pochatok)"
                  psSQLRequest + "VALUES ("
                  psSQLRequest + "'"+NewID+"',"
                  psSQLRequest + "'"+Str(GetGadgetItemData(#Tree_0, GetGadgetState(#Tree_0)))+"',"
                  psSQLRequest + "'"+Str(150114)+"')" ; встановлення дати початку операції за умовчанням 01.01.2012
              EndIf
              If DatabaseUpdate(0, psSQLRequest) = 0
                  MessageRequester("Помилка запиту", DatabaseError())
              Else
                FinishDatabaseQuery(0)
                LastElement(row())
                  AddElement(row())
                  row()\col0=MaxID+1
                  row()\col2=-1
                  row()\col4= 150114 ; встановлення дати початку операції за умовчанням 01.01.2012
                  AddGadgetGridItem(#grid,row()) 
                  rowcount.l = GetRowCount(#grid)
                  SetCurRow(#grid,rowcount-1) ; встати на нову клітинку
              EndIf
          EndIf
            StatusUpdate (BaseRequest)
        Case #ToolDeleteButton                      ; видалити обраний запис
          RowDelete.l=GetGridRow(#grid)
          If ListSize(row())>0
            If MessageRequester("База даних", "Ви впевнені, що бажаєте видалити запис?", #PB_MessageRequester_YesNo) = #PB_MessageRequester_Yes
                FirstElement(row())
                For i=1 To RowDelete
                  NextElement(row())
                Next i
                psSQLRequest = "DELETE FROM [techcards] WHERE id="+ Str(row()\col0)
                If DatabaseUpdate(0, psSQLRequest) = 0
                    MessageRequester("Помилка видалення", DatabaseError())
                Else
                   ; Удаляем выбранный элемент из списка
                   DeleteRow(#grid, RowDelete)
                   DeleteElement(row())
                   Setcurcell(#grid,1,RowDelete-1) ; піднятись на строку вище
                 EndIf
            EndIf 
          EndIf 
          StatusUpdate (BaseRequest)
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0) : SetWindowTitle(#Window_0, #Program_Name) : StatusUpdate ("")
      EndSelect    
    EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure

Procedure Show_TechAmountBar(label$,kilkist$,Name$,Max.l,DataCount.l)
  
  DisableWindow(#Window_0, 1)
              OpenWindow(#Window_1, 0, 0, 950, 640, "Графік використання техніки", #PB_Window_ScreenCentered | #PB_Window_SystemMenu )
              
              nRetVal.l
              nChangeData = #False ; disallow changing the data with a mouseclick                    
              KillTimer_(WindowID(#Window_1),1) ; Kill the timer 
              If nIsChart2
                RMC_DeleteChart(2048)
                nIsChart2 = 0  ; If second chart is existing, delete it
              EndIf
              
              Dim aData.d(DataCount+1)
              
              If RMC_CreateChart(WindowID(#Window_1),2048,10,10,930,615,#ColorWhite,#RMC_CTRLSTYLE3DLIGHT,#False,"","Tahoma")=#RMC_NO_ERROR ; create the chart control
                  RMC_AddRegion(2048,5,5,-5,-5,"",#False)                               ; add a Region to the chart
                  RMC_AddCaption(2048,1,"Графік використання " + Name$,#ColorWhite,#ColorBlack,11,#True) ; add a Caption to region 1
                  RMC_AddGrid(2048,1,#ColorBeige,0,0,0,0,0,#RMC_BICOLOR_LABELAXIS) ; add a Grid to region 1
                  RMC_AddDataAxis(2048,1,#RMC_DATAAXISLEFT,0,Max,Max+1,0,0,0,0,0,"","Кількість") ; add a Data axis to region 1
                  RMC_AddLabelAxis(2048,1, label$,1,0,0,0,0,#RMC_TEXTUPWARD ,0,0,"Дата"); add a Label axis to region 1
                  RMC_SetLAXLineStyle(2048,1,#RMC_LINESTYLENONE) ; No lines for the label axis
                  nC=RMC_Split2Double(kilkist$ ,@aData()) ; read data values into array
                  RMC_AddBarSeries(2048,1,@aData(0),nC,#RMC_BOX_FLAT,#RMC_BOX_NONE) ; add a Bar series To region 1
                  RMC_Draw(2048) ; Draw the chart
  
              EndIf
                      
            Repeat
      Event = WaitWindowEvent()
      Type = EventType()
  If Event = #PB_Event_CloseWindow
    DisableWindow(#Window_0, 0)
    CloseWindow(#Window_1) 
    UseGadgetList(WindowID(#Window_0))
  EndIf    
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
    Select EventGadget()
      Case 2
    EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
         
  
EndProcedure



Procedure Model()
  
  SetWindowTitle(#Window_0, #Program_Name + " - Модель оптимального складу машино-тракторного парку")
  StatusBarProgress(#StatusBar, 1, 5)
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) ;#PB_Container_Raised
  ButtonImageGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24, CatchImage(#icon3,?icon3))  
  
  PanelGadget(#Panel, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35)
  AddGadgetItem(#Panel, -1, "Параметри моделі")
  ListIconGadget(#Listicon_0, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67, "№ п/п", 60, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
    AddGadgetColumn(#Listicon_0, 1, "Параметр моделі", 340)
    AddGadgetColumn(#Listicon_0, 2, "Значення параметра", 120)  
      SetListIconColumnJustification(#Listicon_0, 0, #PB_ListIcon_JustifyColumnRight) 
      SetListIconColumnJustification(#Listicon_0, 2, #PB_ListIcon_JustifyColumnRight) 
    
  AddGadgetItem(#Panel, -1, "Календарний графік робіт")
  ListIconGadget(#Listicon_1, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67, "Господарства", 140, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
  
    AddGadgetColumn(#Listicon_1, 1, "Культури", 140)
    AddGadgetColumn(#Listicon_1, 2, "Технологічні операції", 170)
    AddGadgetColumn(#Listicon_1, 3, "Обсяг робіт, га", 100)  
      
    ; Визначаємо загальну кількість техоперацій
    If DatabaseQuery(0,"SELECT count(*) FROM [techcards]")<>0
      NextDatabaseRow(0)
      Techcount.l = GetDatabaseLong(0, 0) ; кількість техоперацій
    EndIf
    FinishDatabaseQuery(0)  
    If Techcount = 0
      MessageRequester("Увага!", "Відсутні технологічні операції." + Chr(10) + "Неможливо розрахувати модель.")
      CloseGadgetList()
      CloseGadgetList()
      FreeGadget(#Container_0): SetWindowTitle(#Window_0, #Program_Name)
      StatusUpdate("")
      ProcedureReturn 0
    EndIf 
    
    
  AddGadgetItem(#Listicon_0, -1, "1" + Chr(10) + "Загальна кількість технологічних операцій у плані" + Chr(10) +  Str(Techcount))
  StatusBarProgress(#StatusBar, 1, 10)
    
    Dim Duration.l(Techcount-1)   ; масив, у якому зберігаємо тривалість у днях кожної з техоперацій
    Dim Pochatok.l(Techcount-1)   ; масив, у якому зберігаємо дату початку кожної з техоперацій
    
    i.l = 0
     
     If DatabaseQuery(0, "SELECT [techcards].[Pochatok], [operations].[Duration] FROM [techcards] INNER JOIN   [operations] ON [operations].[ID] = [techcards].[ID_operations] ORDER BY [techcards].[Pochatok]")
       While NextDatabaseRow(0)
         Pochatok(i) = GetDatabaseLong(0, 0)  
         Duration(i) = GetDatabaseLong(0, 1)
           i = i + 1
       Wend      
      EndIf 
       
       i.l = 0
       k.l = 0
       d.l = 0
       dateID.l = 0
       dayexist.l = 0
       Dim dateofwork.l(dateID) ; визначення масиву днів, у які є технологічні операції
       
       For i=0 To Techcount-1          ; Цикл усіх техоперацій
         For k = 0 To Duration(i)-1    ; Цикл усіх днів цих операцій
            dayexist = 0                ; Вважаємо, що день ще не вводився в масив
            For d = 0 To dateID        ; Перевіряємо, чи є вже в масиві ця дата. Якщо немає, то додаємо її. Якщо є - ідемо далі
              If dateofwork(d) = Pochatok(i) + k
               dayexist = 1 
              EndIf 
            Next d
            If dayexist = 0
              dateofwork(dateID) = Pochatok(i) + k
              dateID + 1
              ReDim dateofwork(dateID)
            EndIf
         Next k
       Next i
       
    AddGadgetItem(#Listicon_0, -1, "2" + Chr(10) + "Кількість робочих днів у календарному графіку робіт" + Chr(10) +  Str(dateID-1))
    StatusBarProgress(#StatusBar, 1, 15)
       
       dateadd.l
       datestr.s
       For d.l=0 To dateID-1   ; кількість робочих днів
         dateadd = dateofwork(d) - 134774
         datestr = FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, dateadd)) 
         AddGadgetColumn(#Listicon_1, d + 4, datestr, 70)  
       Next d 
    
    psSQLRequest.s = "Select [gospodarstva].[Name], [cultures].[Name], [operations].[Name],"
    psSQLRequest + "  [techcards].[Obsyag], [areas].[Area], [techcards].[Pochatok], [operations].[Duration] "
    psSQLRequest + "FROM [areas] INNER JOIN"
    psSQLRequest + "  [cultures] ON [cultures].[ID] = [areas].[ID_culture] INNER JOIN"
    psSQLRequest + "  [gospodarstva] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva] INNER JOIN"
    psSQLRequest + "  [techcards] ON [areas].[ID] = [techcards].[ID_areas] INNER JOIN"
    psSQLRequest + "  [operations] ON [operations].[ID] = [techcards].[ID_operations]"
    psSQLRequest + "ORDER BY [gospodarstva].[Name], [cultures].[Name], [techcards].[Pochatok]"
    
    rowstring.s
    obsyag.f
    Dim obsyagindex.f(Techcount-1, dateID - 1) 
    
    i.l=0
    If DatabaseQuery(0,psSQLRequest) <> 0
      While NextDatabaseRow(0)
        obsyag = GetDatabaseFloat(0, 3)*GetDatabaseFloat(0, 4)/100
        rowstring = GetDatabaseString(0, 0)+Chr(10)
        rowstring + GetDatabaseString(0, 1)+Chr(10)
        rowstring + GetDatabaseString(0, 2)+Chr(10)
        rowstring + StrF(obsyag,2)+Chr(10)
        ; Заповнюємо обсяги робіт по днях
        For d = 0 To dateID - 1
          If dateofwork(d) = GetDatabaseLong(0, 5)
            For k = 0 To GetDatabaseLong(0, 6)-1
              rowstring + StrF(obsyag / (GetDatabaseLong(0, 6)),2)+Chr(10)
              obsyagindex(i, d+k) = obsyag / (GetDatabaseLong(0, 6))  ; проміжний масив цієї таблиці
            Next k
          Else 
            rowstring +Chr(10)
          EndIf 
        Next d
        AddGadgetItem(#Listicon_1, -1, rowstring)
        i=i + 1
      Wend
    EndIf  
    FinishDatabaseQuery(0)  
    
    SetListIconColumnJustification(#Listicon_1, 3, #PB_ListIcon_JustifyColumnRight) ; вирівнювання 3-ьої колонки по правому боці
    For d.l=0 To dateID-1   ; кількість робочих днів
         SetListIconColumnJustification(#Listicon_1, d + 4, #PB_ListIcon_JustifyColumnRight) ; вирівнювання від 4-ої до останньої колонок по правому боці
    Next d 
    
  ; Формування періодів
  AddGadgetItem(#Panel, -1, "Періоди робіт")
  ListIconGadget(#Listicon_2, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67, "№ п/п", 60, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
    AddGadgetColumn(#Listicon_2, 1, "Дата початку періода", 140)
    AddGadgetColumn(#Listicon_2, 2, "Тривалість періода, днів", 150)  

  Structure Period
    Pochatok_t.l
    Duration_t.l
  EndStructure
  
  Dim indexperiod.period(0)
  
  temp_changesum.l = 0
  indexperiodcount.l = 0
  
  ; Перший день в календарному графіку відноситься до початку першого періода з тривалістю в 1 день
  indexperiod.period(0)\Pochatok_t = dateofwork(0)
  indexperiod.period(0)\Duration_t = 1
  
  For d = 1 To dateID - 1 ; перевірка на зміну обсягу робіт: другий день до першого, третій до другого і т.д.
    For i = 0 To Techcount - 1 ; прохід по рядках таблиці - технологічні операції
      If obsyagindex(i, d) - obsyagindex(i, d - 1) <> 0
      temp_changesum = 1  
      EndIf
    Next i      
    If temp_changesum = 1  ; якщо є зміни, створюється новий період
      indexperiodcount + 1 
      ReDim indexperiod(indexperiodcount)
      indexperiod(indexperiodcount)\Pochatok_t = dateofwork(d) ; новому періоду надається дата
      indexperiod(indexperiodcount)\Duration_t = 0             ; тривалість нового періоду вже має 1 день (поточний)
    EndIf
    temp_changesum = 0    ; обнуляємо рахунок для наступного дня
    indexperiod(indexperiodcount)\Duration_t + 1  ; якщо немає нового періода, збільшуємо тривалість поточного на 1 день
  Next d
  AddGadgetItem(#Listicon_0, -1, "3" + Chr(10) +"Кількість періодів робіт" + Chr(10) + Str(indexperiodcount+1))
  StatusBarProgress(#StatusBar, 1, 20)
  
 For i.l = 0 To indexperiodcount
   rowstring = Str(i) + Chr(10) + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, indexperiod(i)\Pochatok_t - 134774)) + Chr(10) + Str(indexperiod(i)\Duration_t)
   AddGadgetItem(#Listicon_2, -1, rowstring)
 Next i  
 SetListIconColumnJustification(#Listicon_2, 0, #PB_ListIcon_JustifyColumnRight) 
 SetListIconColumnJustification(#Listicon_2, 1, #PB_ListIcon_JustifyColumnRight) 
 SetListIconColumnJustification(#Listicon_2, 2, #PB_ListIcon_JustifyColumnRight) 
 
 ; Формування списку агрегатів та їх шифрів
 AddGadgetItem(#Panel, -1, "Список агрегатів")
  ListIconGadget(#Listicon_3, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67, "Господарство", 160, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection | #PB_ListIcon_HeaderDragDrop)
    AddGadgetColumn(#Listicon_3, 1, "Культури", 90)
    AddGadgetColumn(#Listicon_3, 2, "Технологічна операція", 150)
    AddGadgetColumn(#Listicon_3, 3, "Склад агрегату", 280)
    AddGadgetColumn(#Listicon_3, 4, "Шифр у моделі", 90)  
    AddGadgetColumn(#Listicon_3, 5, "Кількість", 70)  
    AddGadgetColumn(#Listicon_3, 6, "Норма виробітку", 100)  
    AddGadgetColumn(#Listicon_3, 7, "Собівартість, грн./га", 120)  
    AddGadgetColumn(#Listicon_3, 8, "Обсяг робіт за період, га", 140)  
    SetListIconColumnJustification(#Listicon_3, 4, #PB_ListIcon_JustifyColumnCenter) 
    SetListIconColumnJustification(#Listicon_3, 5, #PB_ListIcon_JustifyColumnRight) 
    SetListIconColumnJustification(#Listicon_3, 6, #PB_ListIcon_JustifyColumnRight) 
    SetListIconColumnJustification(#Listicon_3, 7, #PB_ListIcon_JustifyColumnRight) 
    SetListIconColumnJustification(#Listicon_3, 8, #PB_ListIcon_JustifyColumnRight) 
    
    Structure XMTA
      PeriodPochatok.l  ; Дата початку періода
      PeriodDuration.l  ; Тривалість періода
      GospName.s        ; Назва господарства
      CultName.s        ; Назва культури
      TechName.s        ; Назва техоперації
      MTAName.s         ; Склад МТА = Трактор + обладнання
      Shifr.s           ; Шифр агрегата у моделі
      NormDaily.f       ; Денна норма виробітку
      Cost.f            ; Собівартість 1 га обробки
      ObsyagDaily.f     ; Обсяг потрібного виробітку за день
      ObsyagPeriod.f    ; Обсяг потрібного виробітку за період
      TechCardsID.l
      TractorID.l
      MashineryID.l
      Value.f           ; Оптимальна потрібна кількість
    EndStructure
    
    Dim mtaX.XMTA(0)
    
    XMTAcount.l         ; кількість змінних по МТА
    
    For i.l = 0 To indexperiodcount
      StatusBarProgress(#StatusBar, 1, i * 75 / (indexperiodcount + 1)+ 20)
      ;rowstring = Str(i) + "-й період (" + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, indexperiod(i)\Pochatok_t - 134774)) + "; " + Str(indexperiod(i)\Duration_t) + " дн.)"
      ;AddGadgetItem(#Listicon_3, -1, rowstring)
      
      psSQLRequest.s = "SELECT [gospodarstva].[Name], [cultures].[Name], [operations].[Name], [tractors].[Name], [mashinery].[Name], [MTA].[Norma], [MTA].[Cost], [operations].[Duration], [areas].[Area], [techcards].[Obsyag], [techcards].[Pochatok], [techcards].[Pochatok] + [operations].[Duration], [techcards].[ID], [MTA].[ID_tractor], [MTA].[ID_mashinery]"
      psSQLRequest + "FROM [MTA_culture] INNER JOIN [cultures] ON [cultures].[ID] = [MTA_culture].[ID_culture] INNER JOIN [MTA] ON [MTA].[ID] = [MTA_culture].[ID_MTA] INNER JOIN [areas] ON [cultures].[ID] = [areas].[ID_culture] INNER JOIN [techcards] ON [areas].[ID] = [techcards].[ID_areas] INNER JOIN [operations] ON [operations].[ID] = [techcards].[ID_operations] And [operations].[ID] = [MTA].[ID_operation] LEFT JOIN [tractors] ON [tractors].[ID] = [MTA].[ID_tractor] LEFT JOIN [mashinery] ON [mashinery].[ID] = [MTA].[ID_mashinery] INNER JOIN [gospodarstva] ON [gospodarstva].[ID] = [areas].[ID_gospodarstva]" 
      psSQLRequest + " WHERE [techcards].[Pochatok] <" + Str(indexperiod(i)\Pochatok_t+indexperiod(i)\Duration_t) + " And [techcards].[Pochatok] + [operations].[Duration] > " + Str (indexperiod(i)\Pochatok_t)
      psSQLRequest + " ORDER BY [techcards].[Pochatok], [gospodarstva].[Name], [cultures].[Name], [operations].[Name]"
      
      If DatabaseQuery(0, psSQLRequest) <> 0
        While NextDatabaseRow(0)
          XMTAcount.l + 1
          ReDim mtaX(XMTAcount)
          mtaX(XMTAcount)\PeriodPochatok = indexperiod(i)\Pochatok_t
          mtaX(XMTAcount)\PeriodDuration = indexperiod(i)\Duration_t
          mtaX(XMTAcount)\GospName = GetDatabaseString(0, 0)
          mtaX(XMTAcount)\CultName = GetDatabaseString(0, 1)
          mtaX(XMTAcount)\TechName = GetDatabaseString(0, 2)
          mtaX(XMTAcount)\TractorID = GetDatabaseLong(0, 13)
          mtaX(XMTAcount)\MashineryID = GetDatabaseLong(0, 14)
          mtaX(XMTAcount)\MTAName = GetDatabaseString(0, 3) + " + " + GetDatabaseString(0, 4) 
          mtaX(XMTAcount)\Shifr = "a" + Str(XMTAcount)
          mtaX(XMTAcount)\NormDaily = GetDatabaseFloat(0, 5)
          mtaX(XMTAcount)\Cost = GetDatabaseFloat(0, 6)
          mtaX(XMTAcount)\ObsyagDaily = GetDatabaseFloat(0, 8) * GetDatabaseFloat(0, 9) / GetDatabaseLong(0, 7) / 100
          mtaX(XMTAcount)\ObsyagPeriod = mtaX(XMTAcount)\ObsyagDaily * mtaX(XMTAcount)\PeriodDuration
          mtaX(XMTAcount)\TechCardsID = GetDatabaseLong(0, 12)
          ;rowstring = mtaX(XMTAcount)\GospName + Chr(10) + mtaX(XMTAcount)\CultName + Chr(10) + mtaX(XMTAcount)\TechName + Chr(10) + mtaX(XMTAcount)\MTAName + Chr(10) + mtaX(XMTAcount)\Shifr + Chr(10) + StrF(mtaX(XMTAcount)\NormDaily,2) + Chr(10) + StrF(mtaX(XMTAcount)\Cost,2) + Chr(10) + StrF(mtaX(XMTAcount)\ObsyagPeriod,2)
          ;AddGadgetItem(#Listicon_3, -1, rowstring)  
        Wend
      Else
        MessageRequester("Помилка бази", DatabaseError())
      EndIf
    FinishDatabaseQuery(0)
    Next i  
    
    AddGadgetItem(#Listicon_0, -1, "4" + Chr(10) + "Кількість змінних по машино-тракторних агрегатах" + Chr(10) +  Str(XMTAcount))
    
    ; Формування списку тракторів та їх шифрів
    AddGadgetItem(#Panel, -1, "Список енергомашин")
      ListIconGadget(#Listicon_4, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67, "Марка трактора", 180, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
        AddGadgetColumn(#Listicon_4, 1, "Шифр у моделі", 90)
        AddGadgetColumn(#Listicon_4, 2, "Кількість", 70)
        AddGadgetColumn(#Listicon_4, 3, "Балансова вартість, тис. грн.", 170)  
        AddGadgetColumn(#Listicon_4, 4, "Річна зайнятість, год.", 140)  
        SetListIconColumnJustification(#Listicon_4, 1, #PB_ListIcon_JustifyColumnCenter)
        SetListIconColumnJustification(#Listicon_4, 2, #PB_ListIcon_JustifyColumnRight)
        SetListIconColumnJustification(#Listicon_4, 3, #PB_ListIcon_JustifyColumnRight) 
        SetListIconColumnJustification(#Listicon_4, 4, #PB_ListIcon_JustifyColumnRight)
        
    Structure XTractor
      ID.l              ; Код трактора
      Name.s            ; Назва трактора
      Shifr.s           ; Шифр трактора
      Balance.f         ; Балансова вартість
      Yearnorm.f        ; Річна норма зайнятості
      Duration.l        ; Тривалість роботи за техкартами (по всіх можливих операціях)
      Value.f           ; Кількість
    EndStructure
    
    Dim tracX.XTractor(0)
    
    XTractorcount.l
        
        
    psSQLRequest.s = "SELECT [tractors].[ID], [tractors].[Name], [tractors].[Price], [tractors].[Yearnorm], Sum([operations].[Duration])"
    psSQLRequest + "FROM [tractors] INNER JOIN [MTA] ON [tractors].[ID] = [MTA].[ID_tractor] INNER JOIN [operations] ON [operations].[ID] = [MTA].[ID_operation] INNER JOIN [techcards] ON [operations].[ID] = [techcards].[ID_operations] INNER JOIN [MTA_culture] ON [MTA].[ID] = [MTA_culture].[ID_MTA] INNER JOIN [cultures] ON [cultures].[ID] = [MTA_culture].[ID_culture] INNER JOIN [areas] ON [cultures].[ID] = [areas].[ID_culture] And [areas].[ID] = [techcards].[ID_areas]"
    psSQLRequest + "GROUP BY [tractors].[ID] ORDER BY [tractors].[Name]"
    
    If DatabaseQuery(0, psSQLRequest) <> 0
      While NextDatabaseRow(0)
        XTractorcount + 1
        ReDim tracX(XTractorcount)
        tracX(XTractorcount)\ID = GetDatabaseLong(0, 0)
        tracX(XTractorcount)\Name = GetDatabaseString(0, 1)
        tracX(XTractorcount)\Shifr = "a" + Str(XTractorcount + XMTAcount) 
        tracX(XTractorcount)\Balance = GetDatabaseFloat(0, 2)
        tracX(XTractorcount)\Yearnorm = GetDatabaseFloat(0, 3)
        tracX(XTractorcount)\Duration = GetDatabaseLong(0, 4)
        ;rowstring = tracX(XTractorcount)\Name + Chr(10) + tracX(XTractorcount)\Shifr + Chr(10) + StrF(tracX(XTractorcount)\Balance, 1) + Chr(10) + StrF(tracX(XTractorcount)\Yearnorm,1) + Chr(10) + Str(tracX(XTractorcount)\Duration)
        ;AddGadgetItem(#Listicon_4, -1, rowstring) 
      Wend
    Else
      MessageRequester("Помилка бази", DatabaseError())
    EndIf
    FinishDatabaseQuery(0)
     AddGadgetItem(#Listicon_0, -1, "5" + Chr(10) + "Кількість змінних по енергомашинах" + Chr(10) +  Str(XTractorcount))
     
 ; Формування списку сільськогосподарських машин та їх шифрів
    AddGadgetItem(#Panel, -1, "Список с.-г. машин")
      ListIconGadget(#Listicon_5, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67, "Марка машини", 180, #PB_ListIcon_GridLines | #PB_ListIcon_FullRowSelect | #PB_ListIcon_AlwaysShowSelection)
        AddGadgetColumn(#Listicon_5, 1, "Шифр у моделі", 90)
        AddGadgetColumn(#Listicon_5, 2, "Кількість", 70)
        AddGadgetColumn(#Listicon_5, 3, "Балансова вартість, тис. грн.", 170)  
        AddGadgetColumn(#Listicon_5, 4, "Річна зайнятість, год.", 140)  
        SetListIconColumnJustification(#Listicon_5, 1, #PB_ListIcon_JustifyColumnCenter)
        SetListIconColumnJustification(#Listicon_5, 2, #PB_ListIcon_JustifyColumnRight)
        SetListIconColumnJustification(#Listicon_5, 3, #PB_ListIcon_JustifyColumnRight) 
        SetListIconColumnJustification(#Listicon_5, 4, #PB_ListIcon_JustifyColumnRight)
        
    Structure XMash
      ID.l              ; Код машини
      Name.s            ; Назва машини
      Shifr.s           ; Шифр трактора
      Balance.f         ; Балансова вартість
      Yearnorm.f        ; Річна норма зайнятості
      Duration.l        ; Тривалість роботи за техкартами (по всіх можливих операціях)
      Value.f           ; Кількість
    EndStructure
    
    Dim mashX.XMash(0)
    
    XMashcount.l
        
    psSQLRequest.s = "SELECT [mashinery].[ID], [mashinery].[Name], [mashinery].[Price], [mashinery].[Yearnorm], Sum([operations].[Duration])"
    psSQLRequest + "FROM [mashinery] INNER JOIN [MTA] ON [mashinery].[ID] = [MTA].[ID_mashinery] INNER JOIN [operations] ON [operations].[ID] = [MTA].[ID_operation] INNER JOIN [techcards] ON [operations].[ID] = [techcards].[ID_operations] INNER JOIN [MTA_culture] ON [MTA].[ID] = [MTA_culture].[ID_MTA] INNER JOIN [cultures] ON [cultures].[ID] = [MTA_culture].[ID_culture] INNER JOIN [areas] ON [cultures].[ID] = [areas].[ID_culture] And [areas].[ID] = [techcards].[ID_areas]"
    psSQLRequest + "GROUP BY [mashinery].[ID] ORDER BY [mashinery].[Name]"
    
    If DatabaseQuery(0, psSQLRequest) <> 0
      While NextDatabaseRow(0)
        XMashcount + 1
        ReDim mashX(XMashcount)
        mashX(XMashcount)\ID = GetDatabaseLong(0, 0)
        mashX(XMashcount)\Name = GetDatabaseString(0, 1)
        mashX(XMashcount)\Shifr = "a" + Str(XTractorcount + XMTAcount + XMashcount) 
        mashX(XMashcount)\Balance = GetDatabaseFloat(0, 2)
        mashX(XMashcount)\Yearnorm = GetDatabaseFloat(0, 3)
        mashX(XMashcount)\Duration = GetDatabaseLong(0, 4)
        ;rowstring = mashX(XMashcount)\Name + Chr(10) + mashX(XMashcount)\Shifr + Chr(10) + StrF(mashX(XMashcount)\Balance, 1) + Chr(10) + StrF(mashX(XMashcount)\Yearnorm,1) + Chr(10) + Str(mashX(XMashcount)\Duration)
        ;AddGadgetItem(#Listicon_5, -1, rowstring) 
      Wend
    Else
      MessageRequester("Помилка бази", DatabaseError())
    EndIf
    FinishDatabaseQuery(0)
    AddGadgetItem(#Listicon_0, -1, "6" + Chr(10) + "Кількість змінних по с.-г. машинах" + Chr(10) +  Str(XMashcount))
    StatusBarProgress(#StatusBar, 1, 95)
     
    ; Запис задачі ЛП у файл
    
    param.f
    a.s
    If CreateFile(0, "model.txt")         ; Створення текстового файлу, в якому містяться цільова функція і обмеження задачі
      
      
    WriteStringN(0, "/* Agro Tech 1.0 */")  
    WriteStringN(0, "/* Модель лінійного програмування оптимального складу машино-тракторного парку */")
    WriteStringN(0, " ")      
    
    ; Цільова функція
    
    WriteStringN(0, " ")  
    WriteStringN(0, "/* Цільова функція - мінімум приведених витрат */")
    WriteStringN(0, " ")  
    WriteString(0, "min: ")
    
    For i.l = 1 To XMTAcount     ; Добутки по агрегатах
        param = mtaX(i)\PeriodDuration * mtaX(i)\NormDaily * mtaX(i)\Cost
        a = " +" + StrF(param,2) + " " + mtaX(i)\Shifr
        WriteString(0, a)  
    Next i
            
    For i.l = 1 To XTractorcount  ; Добутки по тракторах  
        param = #epsilon * tracX(i)\Balance * 1000 * tracX(i)\Duration * 7 / tracX(i)\Yearnorm
        a = " +" + StrF(param,2) + " " + tracX(i)\Shifr
        WriteString(0, a)  
    Next i
         
    For i.l = 1 To XMashcount     ; Добутки по с.-г. машинах
        param = #epsilon * mashX(i)\Balance * 1000 * mashX(i)\Duration * 7 / mashX(i)\Yearnorm
        a = " +" + StrF(param,2) + " " + mashX(i)\Shifr
        WriteString(0, a)  
    Next i
    
    WriteString(0, ";")
    
    WriteStringN(0, " ")  
    
    WriteStringN(0, "/* Визначення змінних моделі */")
    WriteStringN(0, " ")
    
    For i.l = 1 To XMTAcount      ; Змінні по агрегатах
        a = mtaX(i)\Shifr + " >= 0;"
        WriteStringN(0, a)  
    Next i
       
    For i.l = 1 To XTractorcount  ; Змінні по тракторах
        a = tracX(i)\Shifr + " >= 0;"
        WriteStringN(0, a)  
    Next i
    
    For i.l = 1 To XMashcount  ; Змінні по машинах
        a = mashX(i)\Shifr + " >= 0;"
        WriteStringN(0, a)  
    Next i
            
    ; Формування обмежень щодо обов`язковості виконання заданих обсягів робіт
    
    WriteStringN(0, " ")
    WriteStringN(0, " ")  
    WriteStringN(0, "/* Обмеження щодо обсягів робіт */")
    
    a = ""
    
    For i = 1 To XMTAcount
      If mtaX(i)\TechCardsID <> mtaX(i - 1)\TechCardsID Or mtaX(i)\PeriodPochatok <> mtaX(i - 1)\PeriodPochatok
        If i = 1 
          WriteStringN(0, " ")
          a = "+" + StrF(mtaX(i)\NormDaily * mtaX(i)\PeriodDuration, 2) + " " + mtaX(i)\Shifr
          WriteString(0, a)
        Else
          WriteString(0, " = " + StrF(mtaX(i-1)\ObsyagPeriod,2) + ";")
          WriteStringN(0, " ")
          a = "+" + StrF(mtaX(i)\NormDaily * mtaX(i)\PeriodDuration, 2) + " " + mtaX(i)\Shifr
          WriteString(0, a)
        EndIf
      Else 
        a =  " +" + StrF(mtaX(i)\NormDaily * mtaX(i)\PeriodDuration, 2) + " " + mtaX(i)\Shifr
        WriteString(0, a)
      EndIf
    Next i
    ; Запис значення останнього обмеження
    WriteString(0, " = " + StrF(mtaX(XMTAcount)\ObsyagPeriod,2) + ";")
    WriteStringN(0, " ")
      
    
    ; Формування обмежень щодо неперевищення енергомашин в агрегатах по періодах
    
    WriteStringN(0, " ")  
    WriteStringN(0, "/* Обмеження щодо неперевищення кількості енергомашин в агрегатах по періодах */")
    WriteStringN(0, " ")
    
    a = ""
    includetractor.l = 0
    
    For k = 1 To XTractorcount
      For i = 1 To XMTAcount
            If mtaX(i)\PeriodPochatok <> mtaX(i - 1)\PeriodPochatok
              If i = 1 
                If tracX(k)\ID = mtaX(i)\TractorID
                  WriteString(0, "+ " + mtaX(i)\Shifr + " ")
                  includetractor = 1
                EndIf  
              Else 
                If includetractor = 1 
                  WriteString(0, " <= " + tracX(k)\Shifr + ";")
                  WriteStringN(0, "")
                  includetractor = 0
                EndIf 
                If tracX(k)\ID = mtaX(i)\TractorID
                  WriteString(0, "+ " + mtaX(i)\Shifr + " ")
                  includetractor = 1
                EndIf
              EndIf
            Else
              If tracX(k)\ID = mtaX(i)\TractorID
                WriteString(0, "+ " + mtaX(i)\Shifr + " ")
                includetractor = 1
              EndIf  
            EndIf
      Next i
        ; Запис значення останнього обмеження
        If includetractor = 1 
           WriteString(0, " <= " + tracX(k)\Shifr + ";")
           WriteStringN(0, "")
           includetractor = 0
        EndIf 
    Next k
    
    
    ; Формування обмежень щодо неперевищення  с.-г. машин в агрегатах по періодах
    
    WriteStringN(0, " ")  
    WriteStringN(0, "/* Обмеження щодо неперевищення кількості с.-г. машин в агрегатах по періодах */")
    WriteStringN(0, " ")
    
    a = ""
    includemashinery.l = 0
    
    For k = 1 To XMashcount
      For i = 1 To XMTAcount
            If mtaX(i)\PeriodPochatok <> mtaX(i - 1)\PeriodPochatok
              If i = 1 
                If mashX(k)\ID = mtaX(i)\MashineryID
                  WriteString(0, "+ " + mtaX(i)\Shifr + " ")
                  includemashinery = 1
                EndIf  
              Else 
                If includemashinery = 1 
                  WriteString(0, " <= " + mashX(k)\Shifr + ";")
                  WriteStringN(0, "")
                  includemashinery = 0
                EndIf 
                If mashX(k)\ID = mtaX(i)\MashineryID
                  WriteString(0, "+ " + mtaX(i)\Shifr + " ")
                  includemashinery = 1
                EndIf
              EndIf
            Else
              If mashX(k)\ID = mtaX(i)\MashineryID
                WriteString(0, "+ " + mtaX(i)\Shifr + " ")
                includemashinery = 1
              EndIf  
            EndIf
      Next i
        ; Запис значення останнього обмеження
        If includemashinery = 1 
           WriteString(0, " <= " + mashX(k)\Shifr + ";")
           WriteStringN(0, "")
           includemashinery = 0
        EndIf 
    Next k
    
    ; Закриваємо файл постановки задачі ЛП
    CloseFile(0)    
    
    StatusBarProgress(#StatusBar, 1, 100)
    solution.l = - 1
    
    ; Вирішення задачі лінійного програмування
    If OpenLibrary(0, "lpsolve55.dll")
      New_read_lp = GetFunction(0, "read_LP")
      lp = New_read_lp("model.txt",4,"lp") ; считывает модель ЛП из файла "model.at". lp - указатель на модель
      solve = GetFunction(0, "solve")
      solution = solve(lp)         ; решает модель ЛП в памяти. Если  solution = 0, то решение оптимально
      printf = GetFunction(0, "set_outputfile")
      printf(lp, "solution.txt")               ; определяет вывод полученного решения в файл "print.txt"
      printsol = GetFunction(0, "print_solution")
      printsol(lp, XMTAcount + XTractorcount + XMashcount + 1) ; запись решения задачи в файл. .. - количество переменных
      printf(lp, "objective.txt")               ; определяет вывод полученного решения в файл "print.txt"
      printob = GetFunction(0, "print_objective")
      printob(lp) ; запись целевой функции в файл
      del = GetFunction(0, "delete_lp")
      del(lp)
      ;objective = GetFunction(0, "get_objective")
      ;O.l = objective(lp)
      ;Debug PeekS(@O) 
    Else
      MessageRequester ("Повідомлення", "Не вдалось відкрити файл lpsolve55.dll")  
    EndIf
    
    
    ; Зчитування задачі (моделі в інтерфейс програми)
       
       
    ; Зчитування рішення із файлу і виведення рішення на екран
    Structure solved
      Name.s
      Value.f
    EndStructure
    Dim slv.solved(XMTAcount + XTractorcount + XMashcount + 1)   
    i.l = 0
    If ReadFile(2, "solution.txt")
      While Eof(2) = 0           ; loop as long the 'end of file' isn't reached
        FileLine$ =  ReadString(2)
      Wend
      
      FileLine$ = ReplaceString(FileLine$ , "       ", " ") 
      FileLine$ = ReplaceString(FileLine$ , "  ", " ") 
      FileLine$ = ReplaceString(FileLine$ , "  ", " ") 
      FileLine$ = ReplaceString(FileLine$ , "  ", " ") 
      For k=1 To 8000 ; --------------------------------------------------------------- УТОЧНИТЬ ВОПРОС КОЛИЧЕСТВА ПРОГОНОВ
          strfield$ = StringField(FileLine$ , k, " ")
          If strfield$ <> "" And Left(strfield$,1) = "a"
            i + 1
            slv(i)\Name = strfield$ 
          ElseIf strfield$ <> "" And Left(strfield$,1) <> "a"
            slv(i)\Value = ValF(strfield$)  
          EndIf
      Next k
      CloseFile(2)
    Else
      MessageRequester("Повідомлення","Помилка відкриття файлу", 0)
    EndIf
    
    If ReadFile(3, "objective.txt")
      While Eof(3) = 0           ; loop as long the 'end of file' isn't reached
        FileLine$ =  ReadString(3)
      Wend
      F$ = StringField(FileLine$, 5, " ")
      F.f= ValF(F$)
      ;StatusBarText(#StatusBar, 2, ValF(F$))
      CloseFile(3)
    Else
      MessageRequester("Повідомлення","Помилка відкриття файлу", 0)
    EndIf
    
    ; Запис знайдених змінних до масиву даних
       
    For i = 1 To XMTAcount
      mtaX(i)\Value = slv(i)\Value
    Next i
    
    For i = 1 To XTractorcount
      tracX(i)\Value = slv(i + XMTAcount)\Value
    Next i
    
    For i = 1 To XMashcount
      mashX(i)\Value = slv(i + XMTAcount + XTractorcount )\Value
    Next i
        
      ; Виведення на екран списку агрегатів
      period.l  ; Номер періода робіт
      
                 
      For k = 1 To XMTAcount
        If mtaX(k)\PeriodPochatok <> mtaX(k - 1)\PeriodPochatok 
          rowstring = Str(period) + "-й період (" + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, mtaX(k)\PeriodPochatok - 134774)) + "; " + Str(mtaX(k)\PeriodDuration) + " дн.)"
          AddGadgetItem(#Listicon_3, -1, rowstring)
          period + 1      
        EndIf
          rowstring = mtaX(k)\GospName + Chr(10) + mtaX(k)\CultName + Chr(10) + mtaX(k)\TechName + Chr(10) + mtaX(k)\MTAName + Chr(10) + mtaX(k)\Shifr + Chr(10) + StrF(mtaX(k)\Value,1) + Chr(10) + StrF(mtaX(k)\NormDaily,2) + Chr(10) + StrF(mtaX(k)\Cost,2) + Chr(10) + StrF(mtaX(k)\PeriodDuration * mtaX(k)\NormDaily * mtaX(k)\Value,2)
          AddGadgetItem(#Listicon_3, -1, rowstring)  
      Next k
    
      ; Виведення на екран списку тракторів
      For k = 1 To XTractorcount    
          rowstring = tracX(k)\Name + Chr(10) + tracX(k)\Shifr + Chr(10) + StrF(tracX(k)\Value,1) + Chr(10) + StrF(tracX(k)\Balance, 1) + Chr(10) + StrF(tracX(k)\Yearnorm,1)
          AddGadgetItem(#Listicon_4, -1, rowstring)
          SetGadgetItemData(#Listicon_4, CountGadgetItems(#Listicon_4)-1, tracX(k)\ID)
      Next k    
      
      ; Виведення на екран списку c.-г. машин    
      For k = 1 To XMashcount
          rowstring = mashX(k)\Name + Chr(10) + mashX(k)\Shifr + Chr(10) + StrF(mashX(k)\Value,1) + Chr(10) + StrF(mashX(k)\Balance, 1) + Chr(10) + StrF(mashX(k)\Yearnorm,1)
          AddGadgetItem(#Listicon_5, -1, rowstring) 
          SetGadgetItemData(#Listicon_5, CountGadgetItems(#Listicon_5)-1, mashX(k)\ID)
      Next k    
      
      
      
    Else
      MessageRequester("Повідомлення","Не вдалось створити файл!")
    EndIf
    
    
    If CreateFile(4, "results.txt")         ; Створення текстового файлу, в якому виводиться результат моделі
      
      period.l  = 0 ; Номер періода робіт
      rowstring = "Початок періода" + Chr(9) + "Тривалість періода, днів" + Chr(9) + "Господарство" + Chr(9) + "Культура" + Chr(9) + "Назва операції" + Chr(9) + "Склад МТА" + Chr(9) + "Шифр у моделі" + Chr(9) + "Кількість" + Chr(9) + "Норма виробітку" + Chr(9) + "Витрати, грн./га" + Chr(9) + "Обсяг робіт у цей період, га"
      WriteString(4, rowstring)
                 
      For k = 1 To XMTAcount
        If mtaX(k)\PeriodPochatok <> mtaX(k - 1)\PeriodPochatok
          WriteStringN(4, " ") 
          period + 1      
        EndIf
          If mtaX(k)\Value > 0
            rowstring = FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, mtaX(k)\PeriodPochatok - 134774)) + Chr(9) + Str(mtaX(k)\PeriodDuration) + Chr(9) + mtaX(k)\GospName + Chr(9) + mtaX(k)\CultName + Chr(9) + mtaX(k)\TechName + Chr(9) + mtaX(k)\MTAName + Chr(9) + mtaX(k)\Shifr + Chr(9) + StrF(mtaX(k)\Value,2) + Chr(9) + StrF(mtaX(k)\NormDaily,2) + Chr(9) + StrF(mtaX(k)\Cost,2) + Chr(9) + StrF(mtaX(k)\PeriodDuration * mtaX(k)\NormDaily * mtaX(k)\Value,2)
            WriteString(4, rowstring)
            WriteStringN(4, " ")
          EndIf
      Next k
    Else
      MessageRequester("Повідомлення","Не вдалось створити файл!")
    EndIf
    
    CloseFile(4)
    
    ; Відгук розвязаної моделі виводиться на статусбар
    Select solution 
        Case -2
          StatusBarText(#StatusBar, 1, "Out of memory")
        Case -1
          StatusBarText(#StatusBar, 1, "Помилка, не вдалось вирішити")
        Case 0
          StatusBarText(#StatusBar, 1, "Знайдено оптимальне рішення. F = " + StrF(F,2) + " грн.")
        Case 1
          StatusBarText(#StatusBar, 1, "The model is sub-optimal")
        Case 2
          StatusBarText(#StatusBar, 1, "The model is infeasible")
        Case 3
          StatusBarText(#StatusBar, 1, "The model is unbounded")  
        Case 4
          StatusBarText(#StatusBar, 1, "The model is degenerative")  
        Case 5
          StatusBarText(#StatusBar, 1, "Numerical failure encountered")    
        Case 6
          StatusBarText(#StatusBar, 1, "The abort routine returned TRUE")      
        Case 7
          StatusBarText(#StatusBar, 1, "A timeout occurred")    
        Case 9
          StatusBarText(#StatusBar, 1, "The model could be solved by presolve")      
        Case 10
          StatusBarText(#StatusBar, 1, "The B&B routine failed")      
        Case 11
          StatusBarText(#StatusBar, 1, "The B&B was stopped because of a break-at-first")        
        Case 12
          StatusBarText(#StatusBar, 1, "A feasible B&B solution was found")          
        Case 13
          StatusBarText(#StatusBar, 1, "No feasible B&B solution found")          
      EndSelect     
      
 CloseGadgetList()
 CloseGadgetList()
 
 Dim TrinPeriod.f(0) ; Змінна для виводу кількості траткторів на графік
 Dim MsinPeriod.f(0) ; Змінна для виводу кількості машин на графік
 
Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  WindowNumber = EventWindow()
  If Event = #PB_Event_CloseWindow
          CloseDatabase(0)  ; користувач закрив вікно і програма завершилась
          End
  EndIf    
  If Event =#PB_Event_SizeWindow 
    If IsGadget(#Container_0)
      ResizeGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)) 
    EndIf
    If IsGadget(#Panel)
      ResizeGadget(#Panel, 5, 30, WindowWidth(#Window_0)-10, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-35) 
    EndIf
    If IsGadget(#Listicon_0)
      ResizeGadget(#Listicon_0, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67) 
    EndIf
    If IsGadget(#Listicon_1)
      ResizeGadget(#Listicon_1, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67) 
    EndIf
    If IsGadget(#Listicon_2)
      ResizeGadget(#Listicon_2, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67) 
    EndIf
    If IsGadget(#Listicon_3)
      ResizeGadget(#Listicon_3, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67) 
    EndIf
    If IsGadget(#Listicon_4)
      ResizeGadget(#Listicon_4, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67) 
    EndIf
    If IsGadget(#Listicon_5)
      ResizeGadget(#Listicon_5, 2, 2, WindowWidth(#Window_0)-22, WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar)-67) 
    EndIf
    If IsGadget(#ToolCloseButton)
      ResizeGadget(#ToolCloseButton, WindowWidth(#Window_0)-29, 3, 24, 24) 
    EndIf
  EndIf 
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
      Select EventGadget()
        Case #Listicon_4
          If Type = #PB_EventType_LeftDoubleClick And GetGadgetItemData(#Listicon_4, GetGadgetState(#Listicon_4)) <> 0
            ReDim TrinPeriod(0)       
              ; Формування масиву з датами та кількістю тракторів
              ;ReDim TrinPeriod(1)
              
              ; Знімаємо код трактора з гриду, на якому ми натиснули мишкою двічі
              TracID.l = GetGadgetItemData(#Listicon_4, GetGadgetState(#Listicon_4))
              TrinPeriodCount.l = 0 
              TrinP.l = 0
              ; Цикл проходу по всіх змінних агрегатів
              For i = 1 To XMTAcount
                If mtaX(i)\TractorID = TracID
                  If TrinPeriodCount < mtaX(i)\PeriodPochatok + mtaX(i)\PeriodDuration
                    TrinPeriodCount = mtaX(i)\PeriodPochatok + mtaX(i)\PeriodDuration
                    ReDim TrinPeriod(TrinPeriodCount)       
                  EndIf 
                  
                  For k = 0 To mtaX(i)\PeriodDuration - 1
                    TrinP.l = mtaX(i)\PeriodPochatok + k
                    TrinPeriod(TrinP) = TrinPeriod(TrinP) + mtaX(i)\Value
                  Next k  
                EndIf  
              Next i
              label$ = ""
              kilkist$ = ""
              DataCount.l = 0
              MaxF.f = 0
              For i = mtaX(1)\PeriodPochatok To TrinPeriodCount
                If TrinPeriod(i) > 0
                  label$ + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, i - 134774)) + "*"
                  kilkist$ + StrF(TrinPeriod(i),1) + "*"
                  If MaxF < TrinPeriod(i)
                    MaxF = TrinPeriod(i)
                  EndIf  
                  DataCount + 1
                EndIf  
              Next i
              i = 1
              While tracX(i)\id <> TracID
                i + 1
              Wend
              Name$ = tracX(i)\Name 
              Max.l = MaxF + 1
              
              Show_TechAmountBar (label$,kilkist$, Name$, Max.l,DataCount.l)      
              
          EndIf
        Case #Listicon_5
          If Type = #PB_EventType_LeftDoubleClick And GetGadgetItemData(#Listicon_5, GetGadgetState(#Listicon_5)) <> 0
            ReDim MsinPeriod(0)       
              ; Формування масиву з датами та кількістю тракторів
              ;ReDim TrinPeriod(1)
              
              ; Знімаємо код трактора з гриду, на якому ми натиснули мишкою двічі
              MashID.l = GetGadgetItemData(#Listicon_5, GetGadgetState(#Listicon_5))
              MsinPeriodCount.l = 0 
              MsinP.l = 0
              ; Цикл проходу по всіх змінних агрегатів
              For i = 1 To XMTAcount
                If mtaX(i)\MashineryID = MashID
                  If MsinPeriodCount < mtaX(i)\PeriodPochatok + mtaX(i)\PeriodDuration
                    MsinPeriodCount = mtaX(i)\PeriodPochatok + mtaX(i)\PeriodDuration
                    ReDim MsinPeriod(MsinPeriodCount)       
                  EndIf 
                  
                  For k = 0 To mtaX(i)\PeriodDuration - 1
                    MsinP.l = mtaX(i)\PeriodPochatok + k
                    MsinPeriod(MsinP) = MsinPeriod(MsinP) + mtaX(i)\Value
                  Next k  
                EndIf  
              Next i
              label$ = ""
              kilkist$ = ""
              DataCount.l = 0
              MaxF.f = 0
              For i = mtaX(1)\PeriodPochatok To MsinPeriodCount
                If MsinPeriod(i) > 0
                  label$ + FormatDate("%dd.%mm.%yyyy", AddDate(0, #PB_Date_Day, i - 134774)) + "*"
                  kilkist$ + StrF(MsinPeriod(i),1) + "*"
                  If MaxF < MsinPeriod(i)
                    MaxF = MsinPeriod(i)
                  EndIf  
                  DataCount + 1
                EndIf  
              Next i
              i = 1
              While mashX(i)\id <> MashID
                i + 1
              Wend
              Name$ = mashX(i)\Name 
              Max.l = MaxF + 1
              
              Show_TechAmountBar (label$,kilkist$, Name$, Max.l,DataCount.l)      
          EndIf
        Case #ToolExpButton
        Case #ToolCloseButton      : FreeGadget(#Container_0): SetWindowTitle(#Window_0, #Program_Name)
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
EndProcedure

Procedure Grafik()
  SetWindowTitle(#Window_0, #Program_Name)
  DisableWindow(#Window_0, 1)
  OpenWindow(#Window_1, 0, 0, 950, 640, "Календарний графік робіт", #PB_Window_ScreenCentered | #PB_Window_SystemMenu )
  ButtonGadget(#Button_1, 165, 5, 100, 35, "Зберегти графік")
  GridGadget(#grid,5,5,150, 38,#STYLE_HGRIDLINES | #STYLE_VGRIDLINES | #STYLE_NOCOLSIZE)
  AddGridColumn(#grid,"Початок операцій" ,147,#TYPE_DATE, #GA_ALIGN_RIGHT)
  Structure GDate
      col0.l
  EndStructure 
  
  row.GDate
  row\col0 = Date()/(3600 * 24) + 134774
  AddGadgetGridItem(#grid,row)
  lpData.l = AllocateMemory(500) 
  cell.l= GetCurCell(#grid)
  GetCellData(#grid, cell, lpData)
  date.l = PeekL(lpData)
  Show_FloatingBars(WindowID(#Window_1), date)
  SetActiveGadget(#Button_1)
  
  Repeat
  Event = WaitWindowEvent()
  Type = EventType()
  If Event = #PB_Event_CloseWindow
    DisableWindow(#Window_0, 0)
    CloseWindow(#Window_1) 
    UseGadgetList(WindowID(#Window_0))
  EndIf    
  If Event = #PB_Event_Menu
    MainMenu(EventMenu())           ; процедура очікування дій на головному меню
  EndIf     
  If Event = #PB_Event_Gadget    
    Select EventGadget()
     Case #Button_1
          Protected sFilter.s, Filename.s
          sFilter="Graphic Files (*.jpg*.png)|*.png;*.jpg;*.jpeg;|ALL Files (*.*)|*.*"
          Filename=SaveFileRequester("Зберегти графік","grafik_" + FormatDate("%dd_%mm_%yyyy", AddDate(0, #PB_Date_Day, date - 134774)) +".png",sFilter,0)
          If Filename<>""
            RMC_Draw2File(2048,Filename)
          EndIf
     Case #grid
          Select EventType()
            Case #PB_EventType_Grid_AfterUpdate  
              lpData.l = AllocateMemory(500) 
              cell.l= GetCurCell(#grid)
              GetCellData(#grid, cell, lpData)
              date.l = PeekL(lpData)
              Show_FloatingBars(WindowID(#Window_1), date)
           EndSelect   
      EndSelect    
  EndIf
  Until Event = #PB_Event_CloseWindow
   
EndProcedure

If Not UseSQLiteDatabase()
    MessageRequester("Помилка!", "")
    End
EndIf

If OpenDatabase(0, "DataBase.sqlite", "", "", #PB_Database_SQLite) =0
    MessageRequester("Помилка!","Відсутня база: <DataBase.sqlite>")
    End
EndIf 
  
  ; виконання коду починається з цього вікна
  
If OpenWindow(#Window_0, #PB_Ignore, #PB_Ignore, #WinWidth, #WinHeight, #Program_Name,#PB_Window_SystemMenu | #PB_Window_MaximizeGadget | #PB_Window_MinimizeGadget | #PB_Window_Maximize | #PB_Window_ScreenCentered | #PB_Window_SizeGadget | #PB_Window_BorderLess)
SmartWindowRefresh(#Window_0,1)  
If CreateMenu(#Menu, WindowID(#Window_0))
    MenuTitle("База даних")
          MenuItem(#MenuCheck, "Перевірити базу")
          MenuBar()              
          MenuItem(#MenuClose, "Вийти")
    MenuTitle("Довідники")
          MenuItem(#MenuGospodarstva, "Господарства")
          MenuItem(#MenuCulture, "Культури")
          MenuItem(#MenuOperations, "Операції")
          MenuItem(#MenuTractors, "Енергомашини")
          MenuItem(#MenuMashinery, "С.-г. машини")
    MenuTitle("Плани")
          MenuItem(#MenuAreas, "Посівні площі")
          MenuItem(#MenuMTA, "Агрегати")
          MenuItem(#MenuTechCards, "Технологічні карти")
          MenuBar()             
          MenuItem(#MenuGraf, "Графік робіт")
    MenuTitle("Модель")       
          MenuItem(#MenuModel, "Розрахувати...") 
    MenuTitle("?")
          MenuItem(#MenuAbout, "Про програму")
          MenuBar()             
          MenuItem(#MenuFixed, "Виправлено")
EndIf   
    If CreateStatusBar(#StatusBar, WindowID(#Window_0))
      AddStatusBarField(210)
      AddStatusBarField(350)
      AddStatusBarField(#PB_Ignore) ; autosize this field
      AddStatusBarField(250)
    EndIf
    
    StatusUpdate("") ; Оновлення статусбару  
    
  ContainerGadget(#Container_0, 0, 0, WindowWidth(#Window_0), WindowHeight(#Window_0)-MenuHeight()-StatusBarHeight(#StatusBar))   
  CloseGadgetList()
  
  Repeat
  Event = WaitWindowEvent()
  If Event = #PB_Event_CloseWindow
        CloseDatabase(0) ;
        End
  EndIf    
  
  If Event = #PB_Event_Menu ;
     MainMenu(EventMenu())  
  EndIf     
  Until Event = #PB_Event_CloseWindow

CloseDatabase(0)
EndIf 

DataSection
  icon1: IncludeBinary "plus.ico"
  icon2: IncludeBinary "minus.ico"
  icon3: IncludeBinary "close.ico"
  icon4: IncludeBinary "export.ico"
EndDataSection
  
; IDE Options = PureBasic 4.51 (Windows - x86)
; CursorPosition = 2666
; FirstLine = 2649
; Folding = ---
; EnableXP
; UseIcon = bookpen_hot.ico
; Executable = Compile\AgroTech 1.0.exe