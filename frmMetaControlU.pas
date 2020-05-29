unit frmMetaControlU;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, ExtCtrls, cxStyles, cxCustomData, cxGraphics, cxFilter, cxData,
  cxDataStorage, cxEdit, DB, cxDBData, cxGridLevel, cxClasses, cxControls,
  cxGridCustomView, cxGridCustomTableView, cxGridTableView, cxGridDBTableView,
  cxGrid, ADODB, cxDBLookupComboBox, StdCtrls, Contnrs, dxmdaset, cxDropDownEdit,
  Buttons, ActnList, cxContainer, cxTextEdit, cxMaskEdit, cxLookupEdit,
  cxDBLookupEdit, Menus, FR_Pars, frmEditorU, cxButtonEdit, ImgList,
  cxLookAndFeelPainters, cxButtons, cxLabel, cxDataUtils, cxCheckBox,
  cxHyperLinkEdit, cxGridExportLink, dxBar, dxBarDBNav, dmMainU,
  cxGridBandedTableView, cxGridDBBandedTableView, cxSSheet, cxCalendar,
  IdBaseComponent, IdComponent, IdTCPConnection, IdTCPClient, IdHTTP,
  IdMultipartFormData, cxLookAndFeels, cxCurrencyEdit;



{type
  TEditorItemType = (eitDate, eitList, eitEdit);
 }

type
 // TViewItem = class;

  TCallBackEvent = procedure(Sender: TObject) of object;

  TActionType = (atUnknown, atEdit, atAdd, atPickAdd, atCopyAdd);

  TActionComponent = (acPopup, acButton, acButtonAndPopup);

  TActionProperty = (apNone, apRefresh, apCallBack);

  TViewItemViewType = (vtUnknown, vtView, vtTable, vtStored, vtSingle);

  TViewItemBehaviorLocation = (blClient, blServer);

  TViewItemEditMode = (emUnknown, emAuto, emNone, emEditor, emPick);

  TViewItemDataType = (dtUnknown, dtInt, dtString, dtDate, dtMoney, dtNumeric, dtBit, dtHyperLink, dtCurrency);

  //TViewItemSummary = (smUnknown, smSum);

type
  TViewItem = class;

  TViewItemAction = class
    Name: string;
    Caption: string;
    Open: string;
    ExecSQL: string;
    ActionComponent: TActionComponent;
    ActionIcon: string;
    ActionEnabledValue: string;
    HTTP_POST_SQL: string; {Нужно предоставить переменные ulr и body}
    OwnerViewItem: TViewItem;
    AfterProperty: set of TActionProperty;
    procedure Execute(Sender: TComponent);
  end;

  TViewItemActionList = class(TObjectList)
    function Find(Name: string): TViewItemAction;
  end;

  TViewItemField = class
  private
    FValue: Variant;
    FCaption: string;
    FVisible: boolean;
    function getFieldValue(): Variant;
    procedure setCaption(ACaption: string);
  public
    Name: string;
    DataType: TViewItemDataType;
    reference: string;
    referencehead: string;
    isDynamic: boolean;
    ReferenceViewItem: TViewItem;
    ReferenceHeadViewItem: TViewItem;
    OwnerViewItem: TViewItem;
    Column: TcxGridDBBandedColumn;
    Filter: string;
    ReferenceFilter: string;
    EditMode: TViewItemEditMode;
    Pick: string;
    Actionstr: string;
    Action: TViewItemAction;
    Summary: TcxSummaryKind;
    ColorField: string;
    property Visible: Boolean read FVisible;
    property Caption: string read FCaption write setCaption;
    property Value: Variant read FValue write FValue; {Программно управляем значением поля}
    property FieldValue: Variant read getFieldValue; {Получаем значение из dataset'а}
    procedure CreateColumn(AGridDB: TcxGridTableView; ABandIndex: Integer = 0);
    procedure SaveValue();
    procedure ColumnButtonClick(Sender: TObject; AButtonIndex: Integer);
    procedure SetAction(AActionStr: string);
    procedure gridDBMainColumnPropertiesEditValueChanged(Sender: TObject);
    procedure gridDBMainColumnPropertiesInitPopup(Sender: TObject);
    procedure gridDBMainColumnPropertiesCloseUp(Sender: TObject);
  end;

  TViewItemStyle = class
  public
    Column: TcxGridDBBandedColumn; //Ссылка на колонку, на которую будут стили
    CheckColumn: TcxGridDBBandedColumn; //Ссылка на check колонку для включения стиля.
    Style: TcxStyle;               //Ссылка на Style
  end;

  TViewItemStyleList = class(TObjectList)
    //function Find(Name: string): TViewItemField;
    //procedure SaveValues();
  end;

  TViewItemFieldList = class(TObjectList)
    function Find(Name: string): TViewItemField;
    procedure SaveValues();
  end;
    {
  TViewItemOutContextList = class(TObjectList)
  end;
     }

  TViewItem = class
  private
    FDynamicFields: string;
    FDynamicFieldsQuery: TADODataSet;
    FIsHaveDynamicFields: Boolean;
    FViewType: TViewItemViewType;
    FDataType: TViewItemDataType;
    FDefaultValue: string;
    FIsDefaultValue: Boolean;
    procedure setDefaultValue(ADefaultValue: string);
  public
    CallBackEvent: TCallBackEvent;
    Form: TForm;
    Name: string;
    Caption: string;
    PrimayKey: string;
    ResultField: string;
    Value: Variant;
    Query: TADODataSet;
    MemData: TdxMemData;
    DataSource: TDataSource;
    Component: TComponent;
    BehaviorLocation: TViewItemBehaviorLocation;
    BehaviorEditMode: TViewItemEditMode;
    LeftFixedColumns: Integer;
    spEdit: string;
    spAdd: string;
    spDelete: string;
    Fields: TViewItemFieldList;
    Actions: TViewItemActionList;
    Pick: string;
    PickBackStr: string;
    OpenFormPickMode: Boolean;
    ResyncMode: boolean;
    IncomContext: TViewItem;  {Входящий контекст}
    OutContexts: TList; {Список кому мы отдали конекст}
    StyleList: TViewItemStyleList;
    property ViewType: TViewItemViewType read FViewType;
    property DataType: TViewItemDataType read FDataType;
    property DynamicFieldsQuery: TADODataSet read FDynamicFieldsQuery;
    property IsHaveDynamicFields: Boolean read FIsHaveDynamicFields;
    property DefaultValue: string read FDefaultValue write setDefaultValue;
    property IsDefaultValue: Boolean read FIsDefaultValue;
    constructor Create(Sender: TComponent); overload;
    destructor Destroy; override;
    procedure setDynamicFields(AValue: string);
    procedure SetViewType(AValue: string);
    procedure CreateComponent(AParent: TWinControl);
    procedure mdFilterRecord(DataSet: TDataSet; var Accept: Boolean);
    procedure ListPropertiesInitPopup(Sender: TObject);
    procedure SaveValue();
    procedure SetValue(AValue: Variant);
    procedure PickBack(APickBack: TViewItem);
    procedure Refresh(PKValue: Variant); overload;
    procedure Refresh(); overload;
    procedure Resync(PKValue: Variant); overload;
    procedure Resync(); overload;
    function GetValue(): Variant;
  end;

  TViewItemList = class(TObjectList)
    function Find(Name: string): TViewItem;
    function IndexOf(Name: string): Integer;
    procedure SaveValues();
  end;

type
  TfrmMetaControl = class(TChildForm)
    pnlTop: TPanel;
    gridDBMain: TcxGridDBBandedTableView;
    gridLevelMain1: TcxGridLevel;
    gridMain: TcxGrid;
    adoMT_xmlforms: TADODataSet;
    adoMT_xmlformsID: TIntegerField;
    adoMT_xmlformsxmlpath: TStringField;
    adoMT_xmlformsMainView: TStringField;
    actlistMain: TActionList;
    actRefresh: TAction;
    pnlActions: TPanel;
    btnAdd: TcxButton;
    btnEdit: TcxButton;
    actAdd: TAction;
    actEdit: TAction;
    actDelete: TAction;
    spCustom: TADOStoredProc;
    actCustom: TAction;
    pmActions: TPopupMenu;
    il1: TImageList;
    btnRefresh: TcxButton;
    btnDelete: TcxButton;
    pnlBottom: TPanel;
    edFind: TcxTextEdit;
    actSearchShow: TAction;
    actSearch: TAction;
    btnSearch: TcxButton;
    btnSelect: TcxButton;
    actSelect: TAction;
    btnDropDown: TcxButton;
    actExportXLSX: TAction;
    pmDropDown: TPopupMenu;
    actExportXLSX1: TMenuItem;
    dlgSaveXLS: TSaveDialog;
    dxBarDockControl1: TdxBarDockControl;
    btnCopyAdd: TcxButton;
    actCopyAdd: TAction;
    wewe1: TMenuItem;
    HTTP1: TIdHTTP;
    cxImageList1: TcxImageList;
    gridDBMainColumn1: TcxGridDBBandedColumn;
    StyleRep: TcxStyleRepository;
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure FormDestroy(Sender: TObject);
//    procedure btn3Click(Sender: TObject);
    constructor Create(AOwner: TComponent; MainView: string; Context: Tobject = nil);
    procedure LoadForm(MainView: string; Context: TObject);
    procedure StartMainView(Context: TObject);
    procedure actRefreshExecute(Sender: TObject);
    procedure actAddExecute(Sender: TObject);
    procedure actEditExecute(Sender: TObject);
    procedure actDeleteExecute(Sender: TObject);
    procedure actCustomExecute(Sender: TObject);
    procedure FParserGetValue(const s: string; var v: Variant);
    procedure FParserFunction(const Name: string; p1, p2, p3: Variant; var Val: Variant);
    function DParser(AString: Variant): string;
    procedure FillEditForm(actionType: TactionType);
    procedure gridDBMainCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
    procedure FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure edFindKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure actSearchExecute(Sender: TObject);
    procedure actSearchShowExecute(Sender: TObject);
    procedure gridDBMainCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
    procedure actSelectExecute(Sender: TObject);
    procedure actExportXLSXExecute(Sender: TObject);
    procedure actCopyAddExecute(Sender: TObject);
    procedure HTTP_POST(Url: string; Body: string);
    function AddFile_TemplateImport(Template: Integer): string;
    procedure gridDBMainStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
  private
    ViewItemList: TViewItemList;
    FParser: TfrParser;
    FormFileName: string;
    { Private declarations }
  public
    MainViewItem: TViewItem;
    { Public declarations }
  end;

var
  frmMetaControl: TfrmMetaControl;

implementation

uses
  DateUtils, helperU, LibXmlParser, Math, StrUtils;

{$R *.dfm}

function StrToEditMode(str: string): TViewItemEditMode;
//(emUnknown, emAuto, emNone, emEditor, emPick);
begin
  if (AnsiCompareText(str, 'Auto')) = 0 then
    Result := emAuto
  else if (AnsiCompareText(str, 'None')) = 0 then
    Result := emNone
  else if (AnsiCompareText(str, 'editor')) = 0 then
    Result := emEditor
  else if (AnsiCompareText(str, 'Pick')) = 0 then
    Result := emPick
  else
    result := emUnknown;
end;

function StrToSummary(str: string): TcxSummaryKind;
//skNone, skSum, skMin, skMax, skCount, skAverage);
begin
  if (AnsiCompareText(str, 'Sum')) = 0 then
    Result := skSum
  else if (AnsiCompareText(str, 'Min')) = 0 then
    Result := skMin
  else if (AnsiCompareText(str, 'Max')) = 0 then
    Result := skMax
  else if (AnsiCompareText(str, 'Count')) = 0 then
    Result := skCount
  else if (AnsiCompareText(str, 'Average')) = 0 then
    Result := skAverage
  else
    result := skNone;
end;

function StrToActionComponent(str: string): TActionComponent;
begin
  if (AnsiCompareText(str, 'button')) = 0 then
    Result := acButton
  else if (AnsiCompareText(str, 'ButtonAndPopup')) = 0 then
    Result := acButtonAndPopup
  else
    result := acPopup;
end;

function StrToDataType(str: string): TViewItemDataType;
begin
  if (AnsiCompareText(str, 'int')) = 0 then
    Result := dtInt
  else if (AnsiCompareText(str, 'String')) = 0 then
    Result := dtString
  else if (AnsiCompareText(str, 'Date')) = 0 then
    Result := dtDate
  else if (AnsiCompareText(str, 'Money')) = 0 then
    Result := dtMoney
  else if (AnsiCompareText(str, 'Numeric')) = 0 then
    Result := dtNumeric
  else if (AnsiCompareText(str, 'Bit')) = 0 then
    Result := dtBit
  else if (AnsiCompareText(str, 'HyperLink')) = 0 then
    Result := dtHyperLink
  else if (AnsiCompareText(str, 'Currency')) = 0 then
    Result := dtCurrency
  else
    result := dtUnknown;

end;

function TViewItemField.getFieldValue(): Variant;
begin
  if Self.OwnerViewItem.ViewType in [vtSingle] then
    Result := TcxCustomEdit(Self.OwnerViewItem.Component).EditValue
  else if Self.OwnerViewItem.ViewType in [vtView, vtTable, vtStored] then
    Result := OwnerViewItem.MemData.FieldByName(Self.Name).Value
end;

procedure TViewItemField.setCaption(ACaption: string);
begin
  FCaption := ACaption;
  FVisible := (FCaption <> '');

end;

procedure TViewItem.setDefaultValue(ADefaultValue: string);
begin
  //
  FDefaultValue := ADefaultValue;
  if FDefaultValue <> '' then
    FIsDefaultValue := True;
end;

procedure TViewItem.setDynamicFields(AValue: string);
begin

  if (AValue <> '') or (FDynamicFields <> AValue) then
  begin
    if not Assigned(FDynamicFieldsQuery) then
    begin
      FDynamicFieldsQuery := TADODataSet.Create(Form);
      FDynamicFieldsQuery.Connection := dmMain.Main_ADOConnection;
      FDynamicFieldsQuery.CommandType := cmdStoredProc;
    end;

    with FDynamicFieldsQuery do
    begin
      FIsHaveDynamicFields := true;
      CommandText := AValue;
      Parameters.Refresh;
    end;
  end;
end;

procedure TViewItem.SetViewType(AValue: string);
begin

  FDataType := StrToDataType(AValue);
  if DataType <> dtUnknown then
    FViewType := vtSingle
  else if AnsiCompareText(AValue, 'View') = 0 then
    FViewType := vtView
  else if AnsiCompareText(AValue, 'Table') = 0 then
    FViewType := vtTable
  else if AnsiCompareText(AValue, 'Stored') = 0 then
    FViewType := vtStored
  else if AnsiCompareText(AValue, 'Single') = 0 then
    FViewType := vtSingle;

  with Query do
  begin
    if ((ViewType = vtTable) or (ViewType = vtView)) {and (ViewItem.BehaviorLocation = blClient)} then
    begin
      CommandType := cmdTable;
      CommandText := self.Name;
    end;
    if (ViewType = vtStored) then
    begin
      CommandType := cmdStoredProc;
      CommandText := self.Name;
    end;
    if (ViewType = vtSingle) then
    begin
      CommandType := cmdText;
      CommandText := 'select top 1 ' + self.PrimayKey + ', ' + self.ResultField + ' from ' + self.Name + ' where ' + self.PrimayKey + ' = :@id';
    end;
    Parameters.Refresh;
  end;
end;

constructor TfrmMetaControl.Create(AOwner: TComponent; MainView: string; Context: Tobject = nil);
begin
  inherited Create(AOwner);
  FParser := TfrParser.Create;
  FParser.OnGetValue := FParserGetValue;
  FParser.OnFunction := FParserFunction;
  ViewItemList := TViewItemList.Create;

  LoadForm(MainView, Context);

end;

function TfrmMetaControl.DParser(AString: Variant): string;
var
  News, s: string;
  i: integer;
  v: variant;
begin

{
  qwe := TViewItem(ViewItemList.Find('vCategoryManagers'));

  if Assigned(qwe) then
    qwe.MemData.FieldByName('CategoryID').Value;
 }

  if AString = null then
  begin
    result := '';
    exit;
  end
  else
    s := AString;

  i := 1;
  News := '';
  while (i <= length(s)) do
  begin
    if s[i] = '{' then
    begin
      s := copy(s, 1, i) + DParser(copy(s, i + 1, length(s)));
      inc(i);
    end
    else if (s[i] = '}') then
    begin
      try
        v := FParser.Calc(News);
        News := StringReplace(VarToStrDef(v, 'null'), ',', '.', []);
      except
        ShowMessage('Ошибка при распознании строки: ' + News);
        //frmMain.AddMessage('Ошибка при распознании строки: ' + NewS, 2);
      end;
      result := News + copy(s, i + 1, length(s));
      exit;
    end
    else
    begin
      News := News + s[i];
      inc(i);
    end;

  end;

  Result := News;

end;

procedure TfrmMetaControl.FParserFunction(const Name: string; p1, p2, p3: Variant; var Val: Variant);
begin
  Val := '';
  //ShowMessage('Fun'+Name+' - '+VarToStr(p1) );
  if AnsiCompareText(Name, 'Year') = 0 then
    Val := YearOf(Now);

  if AnsiCompareText(Name, 'Month') = 0 then
    Val := MonthOf(Now);

  if AnsiCompareText(Name, 'Now') = 0 then
    Val := Now;

  if AnsiCompareText(Name, 'Date') = 0 then
    Val := Date;

  if AnsiCompareText(Name, 'IncDay') = 0 then
    Val := IncDay(StrToDate(p1), p2);

  if AnsiCompareText(Name, 'Like') = 0 then
    if Pos(AnsiUpperCase(p1), AnsiUpperCase(p2)) > 0 then
      Val := 1
    else
      Val := 0;

end;

procedure TfrmMetaControl.FParserGetValue(const s: string; var v: Variant);
var
  T: TStringList;
  viField: TViewItemField;
  ViewItem: TViewItem;
var
  i: Integer;

  function GetVar(s: string): string;
  begin
    result := s;
    if Copy(s, 1, 1) = '@' then
    begin
      if AnsiCompareText(s, '@FocusedColumn') = 0 then
      begin
        result := TcxGridDBColumn(gridDBMain.Controller.FocusedColumn).DataBinding.FieldName;
        Exit;
      end;
    end;
  end;

begin

  T := CHelper.SplitString(s, '.');

  with T do
  begin
    {Поле из mainview}
    if Count = 2 then
    begin
      viField := MainViewItem.Fields.Find(GetVar(T.Strings[0]));    {Возвращает колонку по имени}
      if Assigned(viField) then
        with viField do
        begin
          if AnsiCompareText(Strings[1], 'name') = 0 then
            v := viField.name
          else if (AnsiCompareText(Strings[1], 'value') = 0) and (MainViewItem.DataSource.DataSet.RecordCount > 0) then    //Значение поля в гриде
            v := Column.EditValue
          else if (AnsiCompareText(Strings[1], 'reference_value') = 0) or (AnsiCompareText(Strings[1], 'value') = 0) then  //Значение в контроле.
          begin
            viField.ReferenceHeadViewItem.SaveValue();
            v := viField.ReferenceHeadViewItem.Value;
          end
          else if AnsiCompareText(Strings[1], 'values_semicolon') = 0 then  {Возвращает список выбранных строк (primary key) через точку с запятой}
            v := CHelper.GetSelectedString_semicolon(gridDBMain, Column.Index);

        end;
    end
    else
    {Тройная анотация viewitem.field.value}
if Count = 3 then

    begin
      ViewItem := TViewItem(ViewItemList.Find(T.Strings[0]));
      viField := ViewItem.Fields.Find(T.Strings[1]);    {Возвращает колонку по имени}
      if Assigned(viField) then
        with viField do
        begin
          if AnsiCompareText(Strings[2], 'name') = 0 then
            v := viField.name;
          if AnsiCompareText(Strings[2], 'value') = 0 then
            v := FieldValue;

          if AnsiCompareText(Strings[2], 'values_semicolon') = 0 then  {Возвращает список выбранных строк (primary key) через точку с запятой}
            v := CHelper.GetSelectedString_semicolon(gridDBMain, Column.Index);  {TODO это явно не работает}

        end;

    end;

    T.Free;
  end;

end;

constructor TViewItem.Create(Sender: TComponent);
begin
//  inherited;
  self.Fields := TViewItemFieldList.Create();

  self.Actions := TViewItemActionList.Create;

  Self.OutContexts := TList.Create();

  self.StyleList := TViewItemStyleList.Create();

  self.DataSource := TDataSource.Create(Sender);
  Self.Query := TADODataSet.Create(Sender);
  Self.Query.CommandTimeout := 300;
  self.Query.Connection := dmMain.Main_ADOConnection;
  self.DataSource.DataSet := Self.Query;

  self.Form := TForm(Sender);
end;

destructor TViewItem.Destroy;
var
  i: Integer;
begin

  // Освобождение памяти, если она получена
  if Assigned(self.fields) then
    self.Fields.Free;

  if Assigned(self.Actions) then
    self.Actions.Free;

  if Assigned(self.StyleList) then
    self.StyleList.Free;


  {Удаляем все ссылки на себя}
  if Assigned(self.OutContexts) then
  begin
    for i := 0 to self.OutContexts.Count - 1 do
    begin
      TViewItem(self.OutContexts[i]).IncomContext := nil;
    end;
    self.OutContexts.Free;
  end;

  {Удаляем все ссылки на себя}
  if Assigned(self.IncomContext) then
    for i := 0 to self.IncomContext.OutContexts.Count - 1 do
    begin
      if TViewItem(self.IncomContext.OutContexts[i]) = Self then
        self.IncomContext.OutContexts.Delete(i);
    end;


  {
  if Assigned(self.IncomContext) then
    self.IncomContext.Free;
   }
  // Всегда вызывайте родительский деструктор после выполнения вашего собственного кода
  inherited;
end;

function TViewItemActionList.Find(Name: string): TViewItemAction;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if AnsiCompareText(TViewItemAction(Items[i]).Name, Name) = 0 then
    begin
      Result := TViewItemAction(Items[i]);
      exit;
    end;
  end;
  Result := nil;
end;

function TViewItemFieldList.Find(Name: string): TViewItemField;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if AnsiCompareText(TViewItemField(Items[i]).Name, Name) = 0 then
    begin
      Result := TViewItemField(Items[i]);
      exit;
    end;
  end;
  Result := nil;
end;

function TViewItemList.Find(Name: string): TViewItem;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if AnsiCompareText(TViewItem(Items[i]).Name, Name) = 0 then
    begin
      Result := TViewItem(Items[i]);
      exit;
    end;
  end;
  Result := nil;
end;

function TViewItemList.IndexOf(Name: string): Integer;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    if AnsiCompareText(TViewItem(Items[i]).Name, Name) = 0 then
    begin
      Result := i;
      exit;
    end;
  end;
  Result := -1;
end;

function getGroupBox(Caption: string; Sender: TComponent; AParent: TWinControl): TGroupBox;
var
  GroupBox: TGroupBox;
begin
  GroupBox := TGroupBox.Create(Sender);
  GroupBox.Parent := AParent;
  GroupBox.Left := 100;
  GroupBox.Align := alLeft;
  GroupBox.Height := 48;
  GroupBox.Width := 220;
  GroupBox.Caption := Caption;
  Result := GroupBox;
end;

procedure TViewItem.mdFilterRecord(DataSet: TDataSet; var Accept: Boolean);
//var ListFieldNames:string;
var
  Filter: string;
begin
//  ShowMessage(self.ResultField);
//if DataSet.Filter='' then Accept:=True else
  //ListFieldNames:=TcxLookupComboBox(TViewitem(ViewTableList[DataSet.Tag]).Component).Properties.ListFieldNames;

  //Accept := Pos(AnsiUpperCase(DataSet.Filter), AnsiUpperCase(DataSet.FieldByName(self.ResultField).AsString)) > 0; //Like фильтр
    //ShowMessage(DataSet.Owner.Name);

  Filter := AnsiUpperCase(DataSet.Filter);

{  Filter := StringReplace(Filter, '@Lookup.ResultField', AnsiUpperCase(DataSet.FieldByName(self.ResultField).AsString), [rfReplaceAll, rfIgnoreCase]);
  Filter := StringReplace(Filter, '@Lookup.ManagerID', AnsiUpperCase(DataSet.FieldByName('ManagerID').AsString), [rfReplaceAll, rfIgnoreCase]);
 }

  Accept := TfrmMetaControl(DataSet.Owner).DParser(Filter) = '1';
end;

procedure TViewItem.PickBack(APickBack: TViewItem);
begin

  {if Assigned(CallBackEvent) then
  begin
    CallBackEvent(APickBack);
  end


  else}
  if Assigned(Form) then
    if (Form is TfrmMetaControl) then
      with (TfrmMetaControl(Form)) do
      begin
        MainViewItem.Fields.SaveValues;
        MainViewItem.Fields.Find(MainViewItem.PickBackStr).Value := APickBack.Fields.find(APickBack.PrimayKey).Value;
        FillEditForm(atPickAdd);
        APickBack.Resync;

      end;

end;

procedure TViewItem.Resync();
begin
  Resync(null);
end;

procedure TViewItem.Resync(PKValue: variant);
var
  i: Integer;
  ExistRecord: Boolean;
  Parameter: TParameter;
//  PKValue: Variant;
  b: TBookmark;
  NewRec: Boolean;
begin
  if ResyncMode then
    with MemData do
    begin

      DisableControls;
      //b := GetBookmark;
      //TfrmMetaControl(Self.Form).gridDBMain.DataController.SaveBookmark;


      ReadOnly := false;

      if PKValue = null then
        PKValue := FieldByName(Self.PrimayKey).Value
      else
        NewRec := true;

      Parameter := Query.Parameters.FindParam('@' + PrimayKey);
      if Assigned(Parameter) then
      begin
        Parameter.Value := PKValue;
      end;
      Query.Close;
      Query.Open;

      while not Query.Eof do
      begin
        ExistRecord := false;
        if (FieldByName(Self.PrimayKey).Value <> Self.Query.FieldByName(PrimayKey).Value) then
        begin
          if Locate(Self.PrimayKey, Self.Query.FieldByName(PrimayKey).Value, []) then
            ExistRecord := true;
        end
        else
          ExistRecord := true;

        if ExistRecord then
          Edit
        else
          Append;
        for i := 0 to Self.Fields.Count - 1 do
          if Assigned(FindField(TViewItemField(Self.Fields[i]).Name)) then
            FieldByName(TViewItemField(Self.Fields[i]).Name).Value := Self.Query.FieldByName(TViewItemField(Self.Fields[i]).Name).Value;
        post;
        //if not ExistRecord then PKValue := FieldByName(Self.PrimayKey).Value;

        Query.Next;
      end;

      {if recordCount > 0 then
        if BookMarkValid(b) then
          GotoBookmark(b);}
      //TfrmMetaControl(Self.Form).gridDBMain.DataController.GotoBookmark;
      //TfrmMetaControl(Self.Form).gridDBMain.DataController.ClearBookmark;

//      TfrmMetaControl(Self.Form).gridDBMain.DataController.FocusedRecordIndex
//      TfrmMetaControl(Self.Form).gridDBMain.DataController.FilteredIndexByRecordIndex

      {with cxGrid1DBTableView1.DataController do
       for I := 0 to FilteredRecordCount - 1 do
           Memo1.Lines.Add(DisplayTexts[FilteredRecordIndex[I], 0]);}


      if ((NewRec) and (FieldByName(Self.PrimayKey).Value <> PKValue)) then
        Locate(Self.PrimayKey, PKValue, []);
      ReadOnly := true;
      EnableControls;

      with TfrmMetaControl(Self.Form).gridDBMain.DataController do
      begin
        while (FilteredIndexByRecordIndex[FocusedRecordIndex] < 0) and (not eof) do
          Next;

      end;

      if Assigned(Parameter) then
      begin
        Parameter.Value := Null;
      end;
    end
  else
    Refresh(PKValue);

end;

procedure TViewItem.Refresh();
begin
  Refresh(null);
end;

procedure TViewItem.Refresh(PKValue: Variant);
var
  b: TBookmark;
begin

  {if PKValue = null then
        PKValue := FieldByName(Self.PrimayKey).Value;
        }
  try
    Screen.Cursor := crHourGlass;
    CHelper.refreshDataSet(Query);
  finally
    Screen.Cursor := crDefault;
  end;

  if ResyncMode then
    with MemData do
    begin
      b := GetBookmark;
      DisableControls;
      Close;
      ReadOnly := false;
      LoadFromDataSet(Query);
      First;
      //if pfInKey in FindField(PrimayKey).ProviderFlags  then ShowMessage('Флаг');
      FindField(PrimayKey).ProviderFlags := [pfInKey];
      if recordCount > 0 then
        if {recordCount>0} BookMarkValid(b) then
          GotoBookmark(b);
      ReadOnly := true;

      EnableControls;
    end;

  with DataSource.DataSet do
  begin
    if (FieldByName(Self.PrimayKey).Value <> PKValue) and (PKValue <> null) then
      Locate(Self.PrimayKey, PKValue, []);
  end;

end;

procedure TViewItem.CreateComponent(AParent: TWinControl);
var
  cxLookupComboBox: TCxLookupComboBox;
//  cxButtonEdit: TcxButtonEdit;
//  cxDateEdit: TcxDateEdit;
  cxCustomEdit: TcxCustomEdit;
  DS: TDataSource;
  MemData: TdxMemData;
begin

  if (Self.BehaviorLocation = blClient) and (Self.ViewType in [vtTable, vtView, vtStored]) then
  begin
    MemData := TdxMemData.Create(AParent.Owner);
    if not Self.Query.Active then
      Self.Query.Open;
    MemData.LoadFromDataSet(Self.Query);
    //MemData.SortedField := Self.ResultField;
    //MemData.SortOptions := [];
    MemData.First;
    MemData.OnFilterRecord := mdFilterRecord;
    DS := TDataSource.Create(AParent.Owner);
    DS.DataSet := MemData;
    Self.MemData := MemData;
      {
    Если стоит клиент, то забрали данные с query, залили в MemData.
    Используем для фильтрации
    А query используем в лукапе в main grid'е
    }

  end;

  if Self.ViewType in [vtTable, vtView, vtStored] then
  begin
    cxLookupComboBox := TCxLookupComboBox.Create(AParent.Owner);
    with cxLookupComboBox do
    begin
      Parent := AParent; //getGroupBox(Caption);
      Left := 8;
      Top := 16;
      Width := 201;
      Properties.ListSource := DS;
      Properties.KeyFieldNames := Self.PrimayKey;
      Properties.ListFieldNames := Self.ResultField;
      Properties.DropDownListStyle := lsEditList;
      Properties.DropDownSizeable := True;
      Properties.DropDownWidth := 400;
      Properties.ImmediateDropDown := False;
//    Properties.ImmediatePost := true;
      Properties.OnInitPopup := ListPropertiesInitPopup;
    //OnKeyDown := ListKeyDown;
    //EditValue := Value;
    end;
    Self.Component := cxLookupComboBox
  end;

  if (Self.ViewType in [vtSingle]) then
  begin
    if Self.DataType = dtDate then
      cxCustomEdit := TcxDateEdit.Create(AParent.Owner)
    else
      cxCustomEdit := TcxButtonEdit.Create(AParent.Owner);
    with cxCustomEdit do
    begin
      Parent := AParent; //getGroupBox(Caption);
      Left := 8;
      Top := 16;
      Width := 201;
    end;
    Self.Component := cxCustomEdit;
  end;

//  cxDateEdit

end;

procedure TViewItem.ListPropertiesInitPopup(Sender: TObject);
var
  myForm: TfrmMetaControl;
  FilterStr, EditTextStr, ValueStr: string;
  I: integer;
begin
  FilterStr := '';
  myForm := TfrmMetaControl(TcxLookupComboBox(Sender).Owner);

  for I := 1 to Self.Fields.Count - 1 do
    with TViewItemField(Self.Fields[I]) do
      if reference <> '' then
      begin
        myForm.ViewItemList.Find(reference).SaveValue;
        ValueStr := VarToStr(myForm.ViewItemList.Find(reference).Value);
        if ValueStr <> '' then
        begin
          if FilterStr <> '' then
            FilterStr := FilterStr + ' and ';
          FilterStr := FilterStr + '{{' + self.name + '.' + Name + '.value}=' + ValueStr + '}';
        end;
      end;

  {
  myForm := TfrmMetaControl(Self.OwnerViewItem.Form);
  myForm.gridDBMain.BeginUpdate;
  with Self.ReferenceViewItem
  .DataSource.DataSet do
  begin
    Filtered := false;
    Filter := myForm.DParser(Self.ReferenceFilter);
    Filtered := true;
  end;
}
// ShowMessage( TcxLookupComboBox(sender).Properties.ListSource.DataSet.Name);
  EditTextStr := VarToStr(TcxLookupComboBox(Sender).EditText);
  with TcxLookupComboBox(Sender) do
  begin

    Properties.ListSource.DataSet.Filtered := false;
    if (EditTextStr <> '') and (SelText <> Text) then
    begin
      if FilterStr <> '' then
        FilterStr := FilterStr + ' and ';
      FilterStr := FilterStr + '{like(' + EditTextStr + ', {' + self.name + '.' + ResultField + '.value})}';
    end;
    if FilterStr <> '' then
      Properties.ListSource.DataSet.Filter := '{' + FilterStr + '}'
    else
      Properties.ListSource.DataSet.Filter := '';
    if Properties.ListSource.DataSet.Filter <> '' then
      Properties.ListSource.DataSet.Filtered := true;
{
    if SelText = Text then
      Properties.ListSource.DataSet.Filtered := false;
 }
  end;

end;

procedure TfrmMetaControl.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  Action := caFree;
end;

procedure TfrmMetaControl.LoadForm(MainView: string; Context: TObject);
var
  xml: TXmlParser;
  ViewItem: TViewItem;
  viField: TViewItemField;
  viAction: TViewItemAction;
  Style: TcxStyle;
  RGB_str: string;
begin

  adoMT_xmlforms.Parameters[0].Value := MainView;
  adoMT_xmlforms.Open;

  if adoMT_xmlforms.RecordCount = 0 then
  begin
    ShowMessage('Не найдена форма ' + MainView);
    exit;
  end;
  FormFileName := adoMT_xmlformsxmlpath.Value;
  xml := TXmlParser.Create;
  xml.LoadFromFile(adoMT_xmlformsxmlpath.Value);
  xml.StartScan;

  while xml.Scan do
  begin
    if ((xml.CurName = 'ViewTable') and (xml.CurPartType = ptStartTag)) then
    begin
      ViewItem := TViewItem.Create(self);
      ViewItem.Name := xml.CurAttr.Value('Name');
      ViewItem.Caption := xml.CurAttr.Value('Caption');
      ViewItem.PrimayKey := xml.CurAttr.Value('PrimayKey');
      ViewItem.ResultField := xml.CurAttr.Value('ResultField');
      ViewItem.spEdit := xml.CurAttr.Value('SPedit');
      ViewItem.spAdd := xml.CurAttr.Value('SPadd');
      ViewItem.Pick := xml.CurAttr.Value('Pick');
      ViewItem.PickBackStr := xml.CurAttr.Value('PickBack');
      ViewItem.LeftFixedColumns := StrToIntDef(xml.CurAttr.Value('FixCol'), 0);
      ViewItem.spDelete := xml.CurAttr.Value('SPdelete');

      ViewItem.DefaultValue := xml.CurAttr.Value('default');

      ViewItem.setViewType(xml.CurAttr.Value('Type'));

      ViewItem.setDynamicFields(xml.CurAttr.Value('DynamicFieldsQuery'));

      repeat
        xml.Scan;
        if ((xml.CurName = 'behavior') and (AnsiCompareText(xml.CurAttr.Value('location'), 'Client') = 0)) then
          ViewItem.BehaviorLocation := blClient;

        if ((xml.CurName = 'behavior') and (AnsiCompareText(xml.CurAttr.Value('location'), 'Server') = 0)) then
          ViewItem.BehaviorLocation := blServer;

        if (xml.CurName = 'behavior') then
          ViewItem.BehaviorEditMode := StrToEditMode(xml.CurAttr.Value('EditMode'));

        if AnsiCompareText(xml.CurName, 'Style') = 0 then
        begin
          //Style := TcxStyle.Create(Self);
          with StyleRep.CreateItem(TcxStyle) as TcxStyle do
          begin
            Name := xml.CurAttr.Value('Name');
            RGB_str := xml.CurAttr.Value('Color');

            Color := RGB(StrToInt('$' + RGB_str[1] + RGB_str[2]), StrToInt('$' + RGB_str[3] + RGB_str[4]), StrToInt('$' + RGB_str[5] + RGB_str[6]));

          end;

          //viField := TViewItemField.Create;
//          viField.OwnerViewItem := ViewItem;
//          viField.name := xml.CurAttr.Value('Name');
        end;

        if AnsiCompareText(xml.CurName, 'Field') = 0 then
        begin
          viField := TViewItemField.Create;
          viField.OwnerViewItem := ViewItem;
          viField.name := xml.CurAttr.Value('Name');
          viField.Caption := xml.CurAttr.Value('Caption');
          viField.EditMode := StrToEditMode(xml.CurAttr.Value('EditMode'));
          viField.DataType := StrToDataType(xml.CurAttr.Value('Type'));
          viField.Summary := StrToSummary(xml.CurAttr.Value('Summary'));
          viField.Pick := xml.CurAttr.Value('Pick');
          viField.Actionstr := xml.CurAttr.Value('Action');
          viField.reference := xml.CurAttr.Value('Reference');
          viField.ReferenceFilter := xml.CurAttr.Value('ReferenceFilter');
          viField.referencehead := xml.CurAttr.Value('referencehead');
          viField.Filter := xml.CurAttr.Value('Filter');
          viField.ColorField := xml.CurAttr.Value('ColorField');
          ViewItem.Fields.Add(viField);
        end;

        if AnsiCompareText(xml.CurName, 'Action') = 0 then
        begin
          viAction := TViewItemAction.Create;
          viAction.name := xml.CurAttr.Value('Name');
          viAction.Caption := xml.CurAttr.Value('Caption');
          viAction.Open := xml.CurAttr.Value('Open');
          viAction.ExecSQL := xml.CurAttr.Value('ExecSQL');
          viAction.ActionEnabledValue := xml.CurAttr.Value('EnabledValue');
          viAction.ActionComponent := StrToActionComponent(xml.CurAttr.Value('Component'));
          viAction.HTTP_POST_SQL := xml.CurAttr.Value('HTTP_POST_SQL');
          viAction.ActionIcon := xml.CurAttr.Value('Icon');

          viAction.OwnerViewItem := ViewItem;
          if StrToBoolDef(xml.CurAttr.Value('CallBack'), False) then
            viAction.AfterProperty := viAction.AfterProperty + [apCallBack];

          ViewItem.Actions.Add(viAction);
        end;

      until ((xml.CurPartType = ptEndTag) and (xml.CurName = 'ViewTable'));

      ViewItemList.Add(ViewItem);

    end;
  end;

  StartMainView(Context);

end;

procedure TfrmMetaControl.FormDestroy(Sender: TObject);
begin
  if Assigned(ViewItemList) then
    ViewItemList.Free;
  if Assigned(FParser) then
    FParser.Free;
end;

procedure TViewItemField.SetAction(AActionStr: string);
begin
//
end;

procedure TViewItemField.CreateColumn(AGridDB: TcxGridTableView; ABandIndex: Integer = 0);
begin
//   Position.BandIndex = 1
  self.Column := TcxGridDBBandedTableView(AGridDB).CreateColumn;
  TcxGridDBBandedTableView(AGridDB).Bands[ABandIndex].Visible := True;
  with self.Column do
  begin

    Position.BandIndex := ABandIndex;
//    AppearanceHeader.TextOptions.WordWrap :=
    DataBinding.FieldName := self.name;
    Caption := self.Caption;
    Visible := self.Visible;
  //  if self.EditMode in [ emNone] then Options.Editing := false;

    if self.Filter <> '' then
      with AGridDB.DataController.Filter do
      begin
        Root.Clear;
        Root.BoolOperatorKind := fboAnd;
        Root.AddItem(self.Column, foEqual, self.Filter, self.Filter);
        Active := true;
      end;

    if Self.DataType = dtBit then
    begin
      PropertiesClass := TcxCheckBoxProperties;
      TcxCheckBoxProperties(Properties).DisplayChecked := '1';
      TcxCheckBoxProperties(Properties).DisplayUnchecked := '0';
      if self.EditMode in [emNone] then
          TcxCheckBoxProperties(Properties).ReadOnly := true;
      //TcxCheckBoxProperties(Properties).ReadOnly := True;

    end;

    if Self.DataType = dtCurrency then
    begin
      PropertiesClass := TcxCurrencyEditProperties;
      TcxCurrencyEditProperties(Properties).ReadOnly := True;
      TcxCurrencyEditProperties(Properties).DisplayFormat := ',##0.00';
    end;

    if Self.DataType = dtHyperLink then
    begin
      PropertiesClass := TcxHyperLinkEditProperties;
      TcxHyperLinkEditProperties(Properties).Prefix := 'http://';
      TcxHyperLinkEditProperties(Properties).UsePrefix := upAlways;
    end;

    if self.EditMode in [emPick] then
    begin
     //PropertiesClassName := 'TcxButtonEditProperties';
      PropertiesClass := TcxButtonEditProperties;
      TcxButtonEditProperties(Properties).ReadOnly := True;
      TcxButtonEditProperties(Properties).OnButtonClick := ColumnButtonClick;
    end;

    if Assigned(Self.ReferenceViewItem) then
      if Self.ReferenceViewItem.ViewType in [vtView, vtTable, vtStored] then
      begin
          //Делаем Lookup
      //PropertiesClassName := 'TcxLookupComboBoxProperties';
        PropertiesClass := TcxLookupComboBoxProperties;

        TcxLookupComboBoxProperties(Properties).KeyFieldNames := Self.ReferenceViewItem.PrimayKey;
        TcxLookupComboBoxProperties(Properties).ListFieldNames := Self.ReferenceViewItem.ResultField;
        TcxLookupComboBoxProperties(Properties).ListSource := Self.ReferenceViewItem.DataSource;
        TcxLookupComboBoxProperties(Properties).DropDownSizeable := True;
        TcxLookupComboBoxProperties(Properties).DropDownWidth := 400;
//      TcxLookupComboBoxProperties(Properties).SortByDisplayText = isbtOn;
        if self.EditMode in [emNone] then
          TcxLookupComboBoxProperties(Properties).ReadOnly := true;
        Self.ReferenceViewItem.DataSource.DataSet.Open;
        TADODataSet(Self.ReferenceViewItem.DataSource.DataSet).Sort := Self.ReferenceViewItem.ResultField;
        TcxLookupComboBoxProperties(Properties).OnEditValueChanged := gridDBMainColumnPropertiesEditValueChanged;
        if Self.ReferenceFilter <> '' then
        begin
          TcxLookupComboBoxProperties(Properties).OnInitPopup := gridDBMainColumnPropertiesInitPopup;
          TcxLookupComboBoxProperties(Properties).OnCloseUp := gridDBMainColumnPropertiesCloseUp;
        end;
      end;
  end;

//  TcxGridDBBandedTableView(AGridDB)
  if Self.Summary = skSum then
    with TcxGridDBTableSummaryItem(AGridDB.DataController.Summary.FooterSummaryItems.Add) do
    begin
      Kind := Self.Summary;
      Column := self.Column;
//      DisplayText := 'Summary Footer';
    end;

  if ColorField <> '' then
    with TcxGridDBBandedTableView(AGridDB).CreateColumn do
    begin
      Name := ColorField;
      DataBinding.FieldName := ColorField;
      Visible := False;
      //DataBinding.ValueTypeClass := TcxIntegerValueType;
    end;

  // StrToSummary

end;

procedure TfrmMetaControl.StartMainView(Context: TObject);
var
  i: integer;
  MenuItem: TMenuItem;
  viField: TViewItemField;
//  MemData: TdxMemData;
  AParent: TWinControl;
  str_help:string;
begin
  MainViewItem := ViewItemList.Find(adoMT_xmlformsMainView.Value);

  if Assigned(MainViewItem) then
  begin
    MainViewItem.Component := gridDBMain;
    if Context is TViewItem then
    begin
      MainViewItem.IncomContext := TViewItem(Context);
      TViewItem(Context).OutContexts.Add(MainViewItem);
    end;
    //MainViewItem.Form := self;

    Caption := MainViewItem.Caption;
    MainViewItem.DataSource.AutoEdit := False;
    gridDBMain.OptionsData.Editing := False;

    if MainViewItem.BehaviorEditMode = emAuto then
    begin
      MainViewItem.DataSource.AutoEdit := true;
      gridDBMain.OptionsData.Editing := true;
    end;

    if MainViewItem.BehaviorEditMode = emNone then
    begin
      MainViewItem.DataSource.AutoEdit := false;
      gridDBMain.OptionsData.Editing := False;

    end;

    if MainViewItem.BehaviorEditMode in [emNone, emEditor] then
    begin
      if Assigned(MainViewItem.Query.Parameters.FindParam('@' + MainViewItem.PrimayKey)) then
        MainViewItem.ResyncMode := True;
    end;

    if not (MainViewItem.BehaviorEditMode in [emAuto, emEditor]) then
    begin
      actAdd.Enabled := False;
      actEdit.Enabled := False;
      actDelete.Enabled := False;
      actCopyAdd.Enabled := False;
    end;

    if (MainViewItem.BehaviorEditMode in [emEditor]) then
    begin
      if MainViewItem.spAdd = '' then
      begin
        actAdd.Enabled := False;
        actCopyAdd.Enabled := False;
      end;
      if MainViewItem.spEdit = '' then
      begin
        actEdit.Enabled := False;
      end;
      if MainViewItem.spDelete = '' then
      begin
        actDelete.Enabled := False;
      end;

    end;

    if (MainViewItem.ResyncMode) then
    begin

      MainViewItem.MemData := TdxMemData.Create(self);
      MainViewItem.MemData.ReadOnly := true;
      MainViewItem.DataSource.DataSet := MainViewItem.MemData;
//      if not Self.Query.Active then Self.Query.Open;
//      MemData.LoadFromDataSet(Self.Query);
//      MemData.First;


    end;

    gridDBMain.DataController.DataSource := MainViewItem.DataSource;
    gridDBMain.DataController.KeyFieldNames := MainViewItem.PrimayKey;

    for i := 0 to MainViewItem.Fields.Count - 1 do
      with TViewItemField(MainViewItem.Fields[i]) do
      begin

        if Actionstr <> '' then
        begin
          Action := MainViewItem.Actions.Find(Actionstr);
        end;

        if reference <> '' then
        begin
          ReferenceViewItem := ViewItemList.Find(reference);
          ReferenceHeadViewItem := ReferenceViewItem;
        end;
        //В заголовке для фильтров иногда нужна другая view, чем lookup в поле
        if referencehead <> '' then
        begin
          ReferenceHeadViewItem := ViewItemList.Find(referencehead);
        end;


        CreateColumn(gridDBMain, IfThen(i < MainViewItem.LeftFixedColumns, 0, 1));


      //Создает фильтр контролы, если одноименный параметр в процедуре
        if Assigned(MainViewItem.Query.Parameters.FindParam('@' + Name)) then
          if Assigned(ReferenceHeadViewItem) then    //Если фильтр выпадающий компонент
          begin
            str_help := ReferenceHeadViewItem.Caption;
            if str_help = '' then str_help:=Caption;
            ReferenceHeadViewItem.CreateComponent(getGroupBox(str_help, self, pnlTop));
            if ReferenceHeadViewItem.IsDefaultValue then
              ReferenceHeadViewItem.SetValue(DParser(ReferenceHeadViewItem.DefaultValue));
            if Assigned(MainViewItem.IncomContext) then
            begin
              if (MainViewItem.IncomContext.OpenFormPickMode) then
              begin
                if ReferenceHeadViewItem.Component is TCxLookupComboBox then
                  TCxLookupComboBox(ReferenceHeadViewItem.Component).Properties.ReadOnly := true;
              end;
              viField := TViewItem(Context).Fields.Find(Name);
              if Assigned(viField) then
              begin
                ReferenceHeadViewItem.SetValue(viField.value);
             { if Assigned(viField.ReferenceViewItem) then
                ReferenceViewItem.SetValue(TcxCustomEdit(viField.ReferenceViewItem.Component).EditValue)
                }
              end;
            end;
          end
          {else
          begin //Если фильтр обычный Edit
            AParent :=getGroupBox(Caption, self, pnlTop);
            with TcxButtonEdit.Create(AParent.Owner) do
            begin
              Parent :=AParent;
              Left := 8;
              Top := 16;
              Width := 201;

            end;
          end;}

      end;

    if not Assigned(MainViewItem.Fields.Find(MainViewItem.PrimayKey)) then
    begin
      ShowMessage('Primary key "' + MainViewItem.PrimayKey + '" not found in "' + MainViewItem.Name + '"');
      Close;
      exit;
    end;
    with TcxGridDBTableSummaryItem(gridDBMain.DataController.Summary.FooterSummaryItems.Add) do
    begin
      Kind := skCount;
      Column := MainViewItem.Fields.Find(MainViewItem.PrimayKey).Column;
//      DisplayText := 'Summary Footer';
    end;

    for i := 0 to MainViewItem.Actions.Count - 1 do
    begin
      if TViewItemAction(MainViewItem.Actions[i]).ActionComponent in [acButton, acButtonAndPopup] then
      begin
        pnlActions.Width := pnlActions.Width + 47;
        with TcxButton.Create(Self) do
        begin
          //Enabled:=False;
          parent := pnlActions;
          LookAndFeel.Kind := lfOffice11;
          Name := TViewItemAction(MainViewItem.Actions[i]).Name + '_B';
          Left := pnlActions.Width - 48;
          Top := 0;
          Width := 46;
          Height := 46;
          Hint := TViewItemAction(MainViewItem.Actions[i]).Caption;
          //Action = actAdd;
          ParentShowHint := False;
          ShowHint := True;
          TabOrder := 10;
          layout := blGlyphTop;
          OnClick := actCustomExecute;
          Caption := '';
          if FileExists(ExtractFileDir(FormFileName) + TViewItemAction(MainViewItem.Actions[i]).ActionIcon) then
            Glyph.LoadFromFile(ExtractFileDir(FormFileName) + TViewItemAction(MainViewItem.Actions[i]).ActionIcon)
          else
            cxImageList1.GetImage(IfThen(i <= 9, i, 9), Glyph);

        end;
      end;

      if TViewItemAction(MainViewItem.Actions[i]).ActionComponent in [acPopup, acButtonAndPopup] then
      begin
        MenuItem := TMenuItem.Create(pmActions);
        MenuItem.name := TViewItemAction(MainViewItem.Actions[i]).Name + '_M';
        MenuItem.Caption := TViewItemAction(MainViewItem.Actions[i]).Caption;
        MenuItem.OnClick := actCustomExecute;
        if FileExists(ExtractFileDir(FormFileName) + TViewItemAction(MainViewItem.Actions[i]).ActionIcon) then
          MenuItem.Bitmap.LoadFromFile(ExtractFileDir(FormFileName) + TViewItemAction(MainViewItem.Actions[i]).ActionIcon);
//        else
//          cxImageList1.GetImage(IfThen(i <= 9, i, 9), MenuItem.Bitmap);

        pmActions.Items.Add(MenuItem);
      end;
    end;

    if Assigned(MainViewItem.IncomContext) then
    begin
      Show;
      Application.ProcessMessages;

      actRefresh.Execute;
    end;
  end
  else
    ShowMessage('Не найдена MainView: ' + adoMT_xmlformsMainView.Value);

end;

procedure TViewItemField.SaveValue();
var
  val: Variant;
begin
  if Assigned(self.Column) then
  begin
    //TcxCustomEdit(self.Component).PostEditValue;
    self.Value := self.Column.EditValue;

    if Assigned(Self.ReferenceHeadViewItem) then
      if Assigned(Self.ReferenceHeadViewItem.Component) then
      begin
        val := TcxCustomEdit(Self.ReferenceHeadViewItem.Component).EditValue;
        if not (val = null) then
          self.Value := TcxCustomEdit(Self.ReferenceHeadViewItem.Component).EditValue
      end;

  end;
end;

procedure TViewItemFieldList.SaveValues();
var
  i: Integer;
begin
  for i := 0 to self.Count - 1 do
    TViewItemField(self[i]).SaveValue();

end;

procedure TViewItem.SaveValue();
begin
  if Assigned(self.Component) then
  begin
    if self.Component is TcxCustomEdit then
      with TcxCustomEdit(self.Component) do
      begin
        PostEditValue;
        if Self.Component is TcxButtonEdit then
          if VarToStr(EditValue) = '' then
            EditValue := null;
        self.Value := EditValue;
      end;
    if self.Component is TcxGridTableView then
    begin
      self.Value := Self.Query.FieldByName(PrimayKey).Value;
    end;

  end;

end;

function TViewItem.GetValue(): Variant;
begin
  SaveValue();
  if VarToStr(self.Value) = '' then
    Result := null
  else
    Result := self.Value;
end;

procedure TViewItemList.SaveValues();
var
  i: Integer;
begin
  for i := 0 to self.Count - 1 do
    TViewItem(self[i]).SaveValue();

end;

procedure TViewItem.SetValue(AValue: Variant);
begin
  Self.Value := AValue;
  if Assigned(self.Component) then
  begin
    TcxCustomEdit(self.Component).EditValue := self.Value;
  end;

end;

procedure TfrmMetaControl.actRefreshExecute(Sender: TObject);
var
  viField: TViewItemField;
  i, j, ls, lf: Integer;
  Parameter: TParameter;
  str, strStyle, strfield: string;
  ViewItemStyle: TViewItemStyle;
  Column: TcxGridDBBandedColumn;
begin
  gridMain.BeginUpdate;
  for i := 0 to MainViewItem.Fields.Count - 1 do
  begin
    viField := TViewItemField(MainViewItem.Fields[i]);
    if Assigned(viField.ReferenceHeadViewItem) then
      if Assigned(viField.ReferenceHeadViewItem.Component) then
      begin
        viField.ReferenceHeadViewItem.SaveValue();
        MainViewItem.Query.Parameters.FindParam('@' + viField.name).Value := viField.ReferenceHeadViewItem.Value;
        if MainViewItem.IsHaveDynamicFields then
        begin
          Parameter := MainViewItem.DynamicFieldsQuery.Parameters.FindParam('@' + viField.name);
          if Assigned(Parameter) then
            Parameter.Value := viField.ReferenceHeadViewItem.Value;
        end;
      end;

  end;

  for i := MainViewItem.Fields.Count - 1 downto 0 do
  begin    //TODO Переделать на desctructor
    if TViewItemField(MainViewItem.Fields[i]).isDynamic then
    begin
      TViewItemField(MainViewItem.Fields[i]).Column.Destroy;
      if Assigned(gridDBMain.FindItemByName(TViewItemField(MainViewItem.Fields[i]).ColorField)) and (TViewItemField(MainViewItem.Fields[i]).ColorField <> '') then
        gridDBMain.FindItemByName(TViewItemField(MainViewItem.Fields[i]).ColorField).Destroy;
      TObjectList(MainViewItem.Fields).Delete(i);
    end;
      //gridDBMain.Columns[i].Destroy;
  end;

  if MainViewItem.IsHaveDynamicFields then
    with MainViewItem.DynamicFieldsQuery do
    begin
      close;
      Open;
      while not (eof) do
      begin
        viField := TViewItemField.Create;
        viField.name := FieldByName('name').value;
        viField.Caption := FieldByName('caption').value;
        viField.DataType := StrToDataType(FieldByName('type').value);
        viField.EditMode := emAuto;

        if Assigned(FindField('Action')) then
          viField.Actionstr := FieldByName('Action').value;
        if Assigned(FindField('ColorField')) then
          viField.ColorField := FieldByName('ColorField').AsString;

        if viField.Actionstr <> '' then
        begin
          viField.Action := MainViewItem.Actions.Find(viField.Actionstr);
        end;

        viField.isdynamic := true;
//          viField.reference := Xml.CurAttr.Value('Reference');
        MainViewItem.Fields.Add(viField);
        viField.CreateColumn(gridDBMain, 1);
        next;
      end;

      close;
    end;


 { CHelper.refreshDataSet(MainViewItem.Query);
  if MainViewItem.ResyncMode then
    with MainViewItem.MemData do
    begin
      ReadOnly:=false;
      LoadFromDataSet(MainViewItem.Query);
      ReadOnly:=true;
    end;
}
  MainViewItem.Refresh;

  for i := MainViewItem.StyleList.Count - 1 downto 0 do
    with (MainViewItem.StyleList[i] as TViewItemStyle) do
    begin
      CheckColumn.Free;
    end;

  MainViewItem.StyleList.Clear;

  for i := 0 to StyleRep.Count - 1 do
  begin
    strStyle := '__Style_' + StyleRep[i].Name;
    ls := Length(strStyle);

    with (MainViewItem.DataSource.DataSet as TADODataSet) do
      for j := 0 to Fields.Count - 1 do
      begin
        strfield := Fields[j].FieldName;
        lf := Length(strfield);
        str := copy(strfield, lf - ls + 1, ls);
        if AnsiContainsText(str, strStyle) then
        begin
          strfield := copy(strfield, 1, lf - ls);
          ViewItemStyle := TViewItemStyle.Create;

          ViewItemStyle.Column := gridDBMain.GetColumnByFieldName(strfield);
          Column := gridDBMain.CreateColumn;
          with Column do
          begin
            Name := strfield + str;
            DataBinding.FieldName := strfield + str;
            Visible := False;
            DataBinding.ValueTypeClass := TcxBooleanValueType;
          end;
          ViewItemStyle.CheckColumn := Column;
          ViewItemStyle.Style := TcxStyle(StyleRep[i]);
          MainViewItem.StyleList.Add(ViewItemStyle);
          //Memo1.Lines.Add('Для: ' + ViewItemStyle.Column.DataBinding.FieldName + ' есть ' + ViewItemStyle.CheckColumn.DataBinding.FieldName);

        end;
      end;

  end;

  gridMain.EndUpdate;
//  gridDBMain.BeginUpdate;
//  gridDBMain.OptionsBehavior.BestFitMaxRecordCount:=100;
  gridDBMain.ApplyBestFit();
//  gridDBMain.EndUpdate;

  ActiveControl := gridMain;

//  gridDBMain.EndUpdate;
end;

procedure TfrmMetaControl.actCopyAddExecute(Sender: TObject);
begin
  FillEditForm(atCopyAdd);
end;

procedure TfrmMetaControl.actAddExecute(Sender: TObject);
var
  i: integer;
  viField: TViewItemField;
  refViewItem: TViewItem;
//  proc:string;
  response: string;
begin


{
 addList := CHelper.SplitString('AddFile_TemplateImport(180);spPriceCompareFirms_Loaded_Process', ';');
 ShowMessage(addList[0]);
 ShowMessage(addList[1]);
  addList.Free;
 }

// MainViewItem.spadd := 'AddFile_TemplateImport';
  if MainViewItem.spadd = 'triton_upload(268)' then
  begin
    response := AddFile_TemplateImport(268);  //TODO Гвозди убрать.
    if response <> '' then
    begin
      CHelper.spExecute('exec spSyncTable 13');
      CHelper.spExecute('exec spSyncTable 73');
      MainViewItem.Refresh;
    end;
    exit;
  end;

  if MainViewItem.spadd = 'triton_upload(265)' then
  begin
    response := AddFile_TemplateImport(265);  //TODO Гвозди убрать.
    if response <> '' then
    begin
      CHelper.spExecute('exec spSyncTable 13');
      CHelper.spExecute('exec spSyncTable 72');
      MainViewItem.Refresh;
    end;
    exit;
  end;


  if MainViewItem.spadd = 'triton_upload(221)' then
  begin
    response := AddFile_TemplateImport(221);  //TODO Гвозди убрать.
    if response <> '' then
    begin
      CHelper.spExecute('exec spSyncTable 13');
      CHelper.spExecute('exec spSyncTable 54');
      MainViewItem.Refresh;
    end;
    exit;
  end;

  if MainViewItem.spadd = 'triton_upload(205)' then
  begin
    response := AddFile_TemplateImport(205);  //TODO Гвозди убрать.
    if response <> '' then
    begin
      CHelper.spExecute('exec spSyncTable 13');
      CHelper.spExecute('exec spSyncTable 21');
      MainViewItem.Refresh;
    end;
    exit;
  end;

  if MainViewItem.spadd = 'addfile' then
  begin
    response := AddFile_TemplateImport(177);  //TODO Гвозди убрать.
    if response <> '' then
    begin
      CHelper.spExecute('spImport_fileload_price_LoadFile ' + response);
      MainViewItem.Refresh;
    end;
    exit;
  end;

  if MainViewItem.spadd = 'AddFile_TemplateImport' then
  begin
    response := AddFile_TemplateImport(180);  //TODO Гвозди убрать.
    if response <> '' then
    begin
      CHelper.spExecute(DParser('spPriceCompareFirms_Loaded_LoadFile {PriceCompareFirms_id.value}, ') + response);
      MainViewItem.Refresh;
    end;
    exit;
  end;

  if MainViewItem.Pick <> '' then
  begin
    MainViewItem.OpenFormPickMode := true;
    MainViewItem.Fields.SaveValues();
    TfrmMetaControl.Create(Application, MainViewItem.Pick, MainViewItem);
  end
  else
    FillEditForm(atAdd);

    //gridDBMain.DataController.IsBookmarkAvailable

{
  with spCustom do
  begin
    ProcedureName := MainViewItem.spAdd;
    Parameters.Refresh;

      //Будет плясать от того, какие есть вхоядщие параметры
    with TfrmEditor.Create(Self) do
    begin
      try
        SetCaption('Добавить ' + MainViewItem.Caption);
        for i := 0 to MainViewItem.Fields.Count - 1 do
        begin
          viField := TViewItemField(MainViewItem.Fields[i]);
          refViewItem := viField.ReferenceViewItem;
          if Assigned(Parameters.FindParam('@' + viField.name)) then
          begin    //Будет плясать от того, какие есть вхоядщие параметры
            if Assigned(refViewItem) then
            begin
              AddList(viField.name, viField.Caption, viField.ReferenceViewItem.Value, refViewItem.Query, refViewItem.PrimayKey, refViewItem.ResultField);
            end
            else
            begin
              if viField.DataType = dtInt then
                addIntEdit(viField.name, viField.Caption, null);
              if viField.DataType = dtString then
                addStringEdit(viField.name, viField.Caption, null);
              if viField.DataType = dtDate then
                AddDate(viField.name, viField.Caption, null);
              if viField.DataType = dtMoney then
                AddMoney(viField.name, viField.Caption, null);
              if viField.DataType = dtNumeric then
                addNumeric(viField.name, viField.Caption, null);

            end;

          end;

        end;

          //addDate('date', 'Дата заказа', DateToStr(now));
          //addList('firma', 'Поставщик', null, adoWholesaler);

        if ShowModal() = mrOk then
        begin
          for i := 0 to MainViewItem.Fields.Count - 1 do
          begin
            viField := TViewItemField(MainViewItem.Fields[i]);
            refViewItem := viField.ReferenceViewItem;
            if Assigned(Parameters.FindParam('@' + viField.name)) then
            begin
              Parameters.FindParam('@' + viField.name).Value := GetValue(viField.name);
            end;

          end;
          ExecProc;
        end;
      finally
        free;
      end;
    end;

      //ExecProc;
    CHelper.refreshDataSet(MainViewItem.Query);
    gridDBMain.ApplyBestFit();
  end
}

end;

procedure TfrmMetaControl.FillEditForm(actionType: TactionType);
var
  i, j, RecIdx: Integer;
  viField: TViewItemField;
  refViewItem: TViewItem;
  AReadOnly: Boolean;
  Value: Variant;
  Parameter: TParameter;
  isMulti: Boolean;
  isCustomMode: Boolean;
  DataControllerOptions: TcxDataControllerOptions;
begin
  AReadOnly := true;
  if not (actionType = atPickAdd) then
    MainViewItem.Fields.SaveValues;

  if (gridDBMain.DataController.DataSource.DataSet.Active) and not (actionType in [atAdd, atPickAdd, atCopyAdd]) then
    if gridDBMain.Controller.SelectedRowCount > 1 then
      isMulti := True;
    {else if gridDBMain.DataController.RecordCount > 0 then
      gridDBMain.Controller.FocusedRecord.Selected := true;
     }
//  Если режим авто, но прописаны процедцуры для добавления и удаления, то через них
  if (MainViewItem.BehaviorEditMode = emAuto) and (((actionType = atEdit) and (MainViewItem.spEdit <> '')) or ((actionType in [atAdd, atPickAdd, atCopyAdd]) and (MainViewItem.spAdd <> ''))) then
    isCustomMode := True
  else
    isCustomMode := False;

  if (MainViewItem.BehaviorEditMode = emEditor) or isCustomMode then
    with spCustom do
    begin
      if actionType = atEdit then
        ProcedureName := MainViewItem.spEdit;
      if actionType in [atAdd, atPickAdd, atCopyAdd] then
        ProcedureName := MainViewItem.spAdd;
      Parameters.Refresh;

      Parameter := Parameters.FindParam('@CRUD');  //Спец параметр, означает что процедура все умеет.
      if Assigned(Parameter) then
      begin
        if actionType in [atAdd, atPickAdd, atCopyAdd] then
          Parameter.Value := 1;
        if actionType = atEdit then
          Parameter.Value := 2;
      end;

      with TfrmEditor.Create(Self) do
      begin
        try
          if actionType = atEdit then
            SetCaption('Редактировать ' + MainViewItem.Caption);
          if actionType in [atAdd, atPickAdd, atCopyAdd] then
            SetCaption('Добавить ' + MainViewItem.Caption);

          for i := 0 to MainViewItem.Fields.Count - 1 do
          begin
            viField := TViewItemField(MainViewItem.Fields[i]);
            refViewItem := viField.ReferenceViewItem;
            if Assigned(Parameters.FindParam('@' + viField.name)) then
            begin    //Будет плясать от того, какие есть вхоядщие параметры
              if viField.EditMode in [emNone, emPick] then
                AReadOnly := true
              else
                AReadOnly := False;
              Value := Null;

              if actionType = atEdit then
                Value := viField.Column.EditValue;

              if actionType = atCopyAdd then
                if viField.Name <> MainViewItem.PrimayKey then
                  Value := viField.Column.EditValue;

              if actionType = atPickAdd then
                Value := viField.Value;

              if isMulti then
                Value := null;

            //If actionType = atEdit then Value:=viField.Column.EditValue;

              if Assigned(refViewItem) and not (refViewItem.ViewType in [vtSingle]) then
              //if not (refViewItem.ViewType in [vtSingle]) then
              begin
                if actionType in [atAdd, atPickAdd] then
                  Value := viField.ReferenceHeadViewItem.Value;
                if (isMulti and not AReadOnly) or (not isMulti) then
                  AddList(viField.name, viField.Caption, Value, refViewItem.Query, refViewItem.PrimayKey, refViewItem.ResultField, AReadOnly);

              end
              else
              begin

                if viField.DataType = dtInt then
                  addIntEdit(viField.name, viField.Caption, Value, AReadOnly);
                if viField.DataType = dtString then
                  addStringEdit(viField.name, viField.Caption, Value, AReadOnly);
                if viField.DataType = dtDate then
                  AddDate(viField.name, viField.Caption, Value, AReadOnly);
                if viField.DataType = dtMoney then
                  AddMoney(viField.name, viField.Caption, Value, AReadOnly);
                if viField.DataType = dtNumeric then
                  addNumeric(viField.name, viField.Caption, Value, AReadOnly);
                if viField.DataType = dtCurrency then
                  addNumeric(viField.name, viField.Caption, Value, AReadOnly);

              end;

            end;

          end;

          if ShowModal() = mrOk then
          begin
            for i := 0 to MainViewItem.Fields.Count - 1 do
            begin
              viField := TViewItemField(MainViewItem.Fields[i]);
              //refViewItem := viField.ReferenceViewItem;
              if Assigned(Parameters.FindParam('@' + viField.name)) then
              begin
                if GetValue(viField.name) <> null then
                  Parameters.FindParam('@' + viField.name).Value := GetValue(viField.name);
              end;

            end;
            if (isMulti) and (Assigned(Parameters.FindParam('@Multi_id'))) then
            begin
              Parameters.ParamByName('@Multi_id').DataType := ftBlob;
              Parameters.FindParam('@Multi_id').Value := CHelper.GetSelectedString(gridDBMain, MainViewItem.Fields.Find(MainViewItem.PrimayKey).Column.Index);
            end;

            ExecProc;

            if Assigned(Parameters.ParamByName('@' + MainViewItem.PrimayKey)) then
              Value := Parameters.ParamByName('@' + MainViewItem.PrimayKey).Value
            else
              Value := null;

            if (MainViewItem.ResyncMode) and (not isMulti) then
              MainViewItem.Resync(Value)
            else
              MainViewItem.Refresh(Value);

            //MainViewItem.Query.Locate(MainViewItem.PrimayKey, Parameters.ParamByName('@' + MainViewItem.PrimayKey).Value, []);
            gridDBMain.ApplyBestFit();
          end;
        finally
          free;
        end;
      end;

    end
  else if (MainViewItem.BehaviorEditMode = emAuto) or (isMulti) then
  begin
    {if (actionType = atEdit) then
      if gridDBMain.Controller.SelectedRowCount > 1 then
        isMulti := True
      else
        gridDBMain.Controller.FocusedRecord.Selected := true;
}


    with TfrmEditor.Create(Self) do
    begin
      if actionType = atEdit then
        SetCaption('Редактировать ' + MainViewItem.Caption);
      if actionType in [atAdd, atPickAdd, atCopyAdd] then
        SetCaption('Добавить ' + MainViewItem.Caption);

      for i := 0 to MainViewItem.Fields.Count - 1 do
      begin
        viField := TViewItemField(MainViewItem.Fields[i]);
        refViewItem := viField.ReferenceViewItem;

        if viField.EditMode in [emNone, emPick] then
          AReadOnly := true
        else
          AReadOnly := False;
        Value := Null;

        if actionType = atEdit then
          Value := viField.Column.EditValue;

        if actionType = atCopyAdd then
          if viField.Name <> MainViewItem.PrimayKey then
            Value := viField.Column.EditValue;

        if actionType = atPickAdd then
          Value := viField.Value;
        if isMulti then
          Value := null;

            //If actionType = atEdit then Value:=viField.Column.EditValue;

        if Assigned(refViewItem) and not (refViewItem.ViewType in [vtSingle]) then
        begin
          if actionType in [atAdd, atPickAdd] then
            Value := viField.ReferenceHeadViewItem.Value;
          if ((isMulti and not AReadOnly) or (not isMulti)) and (viField.ReferenceHeadViewItem.ViewType in [vtTable, vtView, vtStored]) then
            AddList(viField.name, viField.Caption, Value, refViewItem.Query, refViewItem.PrimayKey, refViewItem.ResultField, AReadOnly);
        end
        else
        begin
          if viField.DataType = dtInt then
            if (isMulti and not AReadOnly) or (not isMulti) then
              addIntEdit(viField.name, viField.Caption, Value, AReadOnly);
          if viField.DataType = dtString then
            if (isMulti and not AReadOnly) or (not isMulti) then
              addStringEdit(viField.name, viField.Caption, Value, AReadOnly);
          if viField.DataType = dtDate then
            if (isMulti and not AReadOnly) or (not isMulti) then
              AddDate(viField.name, viField.Caption, Value, AReadOnly);
          if viField.DataType = dtMoney then
            if (isMulti and not AReadOnly) or (not isMulti) then
              AddMoney(viField.name, viField.Caption, Value, AReadOnly);
          if viField.DataType = dtNumeric then
            if (isMulti and not AReadOnly) or (not isMulti) then
              addNumeric(viField.name, viField.Caption, Value, AReadOnly);
          if viField.DataType = dtCurrency then
            if (isMulti and not AReadOnly) or (not isMulti) then
              addNumeric(viField.name, viField.Caption, Value, AReadOnly);

        end;
      end;
      if ShowModal() = mrOk then
      begin
        if (actionType in [atAdd, atCopyAdd]) then
        begin
          gridDBMain.Controller.ClearSelection;
          gridDBMain.DataController.Append;
          gridDBMain.Controller.FocusedRecord.Selected := true;
        end;

        if true then
        begin
          try
            Screen.Cursor := crHourGlass;
            gridDBMain.BeginUpdate;

            DataControllerOptions := gridDBMain.DataController.Options;
            gridDBMain.DataController.Options := DataControllerOptions - [dcoImmediatePost];

           // if  (dcoImmediatePost in gridDBMain.DataController.OptionsData)   then ShowMessage('df');
            //gridDBMain.OptionsData := gridDBMain.OptionsData-1;
            for j := 0 to gridDBMain.Controller.SelectedRowCount - 1 do
            begin
              RecIdx := gridDBMain.Controller.SelectedRecords[j].RecordIndex;
              gridDBMain.DataController.FocusedRecordIndex := RecIdx;
              for i := 0 to MainViewItem.Fields.Count - 1 do
              begin
                viField := TViewItemField(MainViewItem.Fields[i]);
                if viField.EditMode in [emAuto] then
                begin
                  Value := GetValue(viField.Name);
                  if ((isMulti) and Value <> null) or (not isMulti) then
                    gridDBMain.DataController.SetEditValue(viField.Column.Index, Value, evsValue);
                end
              end;
            end;
            gridDBMain.DataController.Post;

          finally
            gridDBMain.DataController.Options := DataControllerOptions;

            Screen.Cursor := crDefault;
            gridDBMain.EndUpdate;
          end;

        end
        else
        begin

        end;
      end;
    end;
  end;

end;

procedure TfrmMetaControl.actEditExecute(Sender: TObject);
var
  i: integer;
  viField: TViewItemField;
  refViewItem: TViewItem;
  AReadOnly: Boolean;
begin
  FillEditForm(atEdit);
end;

procedure TfrmMetaControl.actDeleteExecute(Sender: TObject);
var
  ParamKey: TParameter;
  Parameter: TParameter;
  isCustomMode: Boolean;
  isMulti: Boolean;
  question: string;
begin
  if (gridDBMain.DataController.DataSource.DataSet.Active) then
    if gridDBMain.Controller.SelectedRowCount > 1 then
      isMulti := True;

  if (MainViewItem.BehaviorEditMode = emAuto) and (MainViewItem.spDelete <> '') then
    isCustomMode := True
  else
    isCustomMode := False;

  if (MainViewItem.BehaviorEditMode = emAuto) and not isCustomMode then
  begin
    if isMulti then
      question := 'Удалить записей:' + VarToStr(gridDBMain.Controller.SelectedRowCount)
    else
      question := 'Удалить запись номер:' + VarToStr(MainViewItem.DataSource.DataSet.FieldByName(MainViewItem.PrimayKey).Value);
    if MessageBox(handle, PChar(question), PChar('Удаление'), MB_YESNO + MB_ICONQUESTION) = idyes then
    begin
      gridDBMain.DataController.DeleteFocused;
    end;
  end
  else

    with spCustom do
    begin
      ProcedureName := MainViewItem.spDelete;
      Parameters.Refresh;

      Parameter := Parameters.FindParam('@CRUD');
      if Assigned(Parameter) then
        Parameter.Value := 3;

      ParamKey := Parameters.FindParam('@' + MainViewItem.PrimayKey);
      if Assigned(ParamKey) then
      begin
        ParamKey.Value := MainViewItem.DataSource.DataSet.FieldByName(MainViewItem.PrimayKey).Value;
        if isMulti then
          question := 'Удалить записей:' + VarToStr(gridDBMain.Controller.SelectedRowCount)
        else
          question := 'Удалить запись номер:' + VarToStr(ParamKey.Value);
        if MessageBox(handle, PChar(question), PChar('Удаление'), MB_YESNO + MB_ICONQUESTION) = idyes then
        begin
          if (isMulti) and (Assigned(Parameters.FindParam('@Multi_id'))) then
          begin
            Parameters.ParamByName('@Multi_id').DataType := ftBlob;
            Parameters.FindParam('@Multi_id').Value := CHelper.GetSelectedString(gridDBMain, MainViewItem.Fields.Find(MainViewItem.PrimayKey).Column.Index);
          end;
          ExecProc;
          MainViewItem.Refresh;
          gridDBMain.ApplyBestFit();
        end;
      end
      else
        ShowMessage('Не могу найти ключ:' + MainViewItem.PrimayKey);
    end

//CHelper.spExecute(MainViewItem.Delete, MainViewItem.PrimayKey)

end;

procedure TViewItemAction.Execute(Sender: TComponent);
var
  v: Variant;
  Context: TViewItem;
  q: TADODataSet;
begin

  if self.HTTP_POST_SQL <> '' then
  begin
    v := TfrmMetaControl(Sender).DParser(self.HTTP_POST_SQL);
    q := TADODataSet.Create(Sender);

    q.Connection := dmMain.Main_ADOConnection;
    q.CommandType := cmdText;
    q.CommandText := VarToStr(v);
    q.Open;

    TfrmMetaControl(Sender).HTTP_POST(q.FieldByName('url').Value, q.FieldByName('body').Value);

    q.Free;

  end;

  if self.ExecSQL <> '' then
  begin
    v := TfrmMetaControl(Sender).DParser(self.ExecSQL);

    try
      Screen.Cursor := crHourGlass;
      CHelper.spExecute(VarToStr(v));
    finally
      Screen.Cursor := crDefault;
    end;
    TfrmMetaControl(Sender).MainViewItem.Resync;

    if apCallBack in self.AfterProperty then
      if Assigned(Self.OwnerViewItem.IncomContext) then
        if Self.OwnerViewItem.IncomContext <> nil then
        begin
          Self.OwnerViewItem.IncomContext.CallBackEvent(Self.OwnerViewItem);
        end;

  end;

  if self.Open <> '' then
  begin
    v := TfrmMetaControl(Sender).DParser(self.Open);

    TfrmMetaControl(Sender).MainViewItem.OpenFormPickMode := False;
    TfrmMetaControl(Sender).MainViewItem.Fields.SaveValues();

//    Context.assign(TfrmMetaControl(Sender).MainViewItem);
    TfrmMetaControl.Create(Application, v, TfrmMetaControl(Sender).MainViewItem);
  end;

end;

procedure TfrmMetaControl.actCustomExecute(Sender: TObject);
//var StringList : TStringList;
var
  s: string;
  v: Variant;
  viAction: TVIewItemAction;
begin
  s := TMenuItem(Sender).Name;

  SetLength(s, Length(s) - 2);
  //ShowMessage(TcxGridDBColumn(gridDBMain.Controller.FocusedColumn).DataBinding.FieldName);
  //TODO Нужен тип Actions
  viAction := MainViewItem.Actions.Find(s);
  if Assigned(viAction) then
    viAction.Execute(self);
    //ShowMessage(s);
  {
  with viActrion do
  begin

    if ExecSQL <> '' then
    begin
      v := DParser(ExecSQL);
      CHelper.spExecute(VarToStr(v));
      CHelper.refreshDataSet(MainViewItem.Query);
    end;

    if Open <> '' then
    begin
      MainViewItem.Fields.SaveValues();
      TfrmMetaControl.Create(Application, Open, MainViewItem);
    end;

  end;
  }

  //ShowMessage(VarToStr(v));

{
  with CHelper.SplitString('qwe.err','.') do begin
  ShowMessage(Strings[0]);
  ShowMessage(Strings[1]);
    Free;
  end;
}

//ShowMessage(VarToStr(MainViewItem.Fields.Find(TcxGridDBColumn(gridDBMain.Controller.FocusedColumn).DataBinding.FieldName).Column.EditValue));

end;

procedure TViewItemField.ColumnButtonClick(Sender: TObject; AButtonIndex: Integer);
begin
//
//  ShowMessage(Self.Pick);
end;

procedure TfrmMetaControl.gridDBMainCellDblClick(Sender: TcxCustomGridTableView; ACellViewInfo: TcxGridTableDataCellViewInfo; AButton: TMouseButton; AShift: TShiftState; var AHandled: Boolean);
var
  viField: TViewItemField;
begin

  viField := MainViewItem.Fields.Find(TcxGridDBColumn(gridDBMain.Controller.FocusedColumn).DataBinding.FieldName);
  if Assigned(viField) then
    if Assigned(viField.Action) then
    begin  //Action
      viField.Action.Execute(Self);
      Exit;
    end;

  if Assigned(MainViewItem.IncomContext) then
    if MainViewItem.IncomContext <> nil then
   //Pick режим подбора
      if MainViewItem.IncomContext.OpenFormPickMode then
      begin
        MainViewItem.Fields.SaveValues();
        MainViewItem.IncomContext.PickBack(MainViewItem);
        Exit;
      end;

  if MainViewItem.BehaviorEditMode in [emUnknown, emNone, emEditor, emAuto] then
  begin //Обычный режим
    actEdit.Execute;
    Exit;
  end;
      //ShowMessage(VarToStr(MainViewItem.Fields.Find(MainViewItem.PrimayKey).Column.EditValue));


end;

procedure TfrmMetaControl.FormKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  viField: TViewItemField;
begin

  if Key = VK_ESCAPE then
  begin
    if Assigned(MainViewItem.IncomContext) then
      if MainViewItem.IncomContext.OpenFormPickMode then
      begin
        close;
      end;
  end;

  if Key = VK_RETURN then
  begin
    if Assigned(MainViewItem.IncomContext) then
      if MainViewItem.IncomContext.OpenFormPickMode then
      begin
        MainViewItem.Fields.SaveValues();
        MainViewItem.IncomContext.PickBack(MainViewItem);
        Exit;
      end;
   {
    if MainViewItem.BehaviorEditMode in [emUnknown, emNone, emEditor] then
    begin
      actEdit.Execute;
      exit;
    end;
    }
  end;

  if Key = VK_SPACE then
  begin
    viField := MainViewItem.Fields.Find(TcxGridDBColumn(gridDBMain.Controller.FocusedColumn).DataBinding.FieldName);
    if Assigned(viField) then
      if Assigned(viField.Action) then
      begin
        viField.Action.Execute(Self);
      end;
  end;

end;

procedure TViewItemField.gridDBMainColumnPropertiesEditValueChanged(Sender: TObject);
var
  ADataSet: TADODataSet;
begin
//   Sender.ClassName;
  with TADODataSet(self.Column.DataBinding.Field.Owner) do
  begin
    if State = dsEdit then
      post;

  end;
 {
  ADataSet := TADODataSet(TcxLookupComboBox(Sender).DataBinding.DataSource.DataSet);
  if ADataSet.State = dsEdit then
    ADataSet.Post;
  }
end;

procedure TfrmMetaControl.edFindKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key = VK_RETURN then
  begin
    actSearch.Execute;
  end;
end;

procedure TfrmMetaControl.actSearchExecute(Sender: TObject);
begin
//
//TcxGridTableView;
  if gridDBMain.DataController.DataSource.DataSet.Active then
    if not CHelper.SearchIncxGrid(gridDBMain, edFind.Text, false) then
      CHelper.SearchIncxGrid(gridDBMain, edFind.Text, true)

end;

procedure TfrmMetaControl.actSelectExecute(Sender: TObject);
var
  isFisrt: Boolean;
begin
  isFisrt := True;
  gridDBMain.BeginUpdate;
  if Assigned(gridDBMain.FindItemByName('Color')) then
  begin
    gridDBMain.FindItemByName('Color').Free;
  end;

  with gridDBMain.CreateColumn do
  begin
    Name := 'Color';
    Visible := False;
    DataBinding.ValueTypeClass := TcxBooleanValueType;
  end;

  if gridDBMain.DataController.DataSource.DataSet.Active then
    while CHelper.SearchIncxGrid(gridDBMain, edFind.Text, isFisrt) do
    begin
      isFisrt := False;
      gridDBMain.FindItemByName('Color').EditValue := true;
      //gridDBMainColor.EditValue :=true;
      //gridDBMain.ViewData.Records[1].Selected := True;
    end;
  gridDBMain.EndUpdate;
end;

procedure TfrmMetaControl.actSearchShowExecute(Sender: TObject);
begin
  edFind.SetFocus;
  edFind.SelectAll;
end;

procedure TfrmMetaControl.gridDBMainCustomDrawCell(Sender: TcxCustomGridTableView; ACanvas: TcxCanvas; AViewInfo: TcxGridTableDataCellViewInfo; var ADone: Boolean);
var
  ARec: TRect;
  color: Variant;
begin

  if Assigned(gridDBMain.FindItemByName('Color')) and (not AViewInfo.Selected) then
    if (AViewInfo.GridRecord.Values[gridDBMain.FindItemByName('Color').Index] = true) then
      ACanvas.Brush.Color := $FFEEEE;

  if (AViewInfo.Selected) and (Screen.ActiveControl <> Sender.Site) then
  begin
    ACanvas.Brush.Color := clLtGray;
//    ACanvas.Font.Color := clFuchsia;
  end;

end;

procedure TfrmMetaControl.actExportXLSXExecute(Sender: TObject);
var
  i: Integer;
begin
//
//       --TcxGridDBView().


  with dlgSaveXLS do
  begin
    Filter := 'All|*.*|Ecxel|*.xlsx;*.xls';
    DefaultExt := 'xlsx';
    FilterIndex := 2;
    FileName := self.Caption;

   { for i := 0 to MainViewItem.Fields.Count - 1 do
      with TViewItemField(MainViewItem.Fields[i]) do
        if Assigned(ReferenceHeadViewItem) then
          if Assigned(ReferenceHeadViewItem.Component) then
            if ReferenceHeadViewItem.Value <> null then
              if ReferenceHeadViewItem.Component is TcxLookupComboBox then
                FileName := FileName + '-' + TcxLookupComboBox(ReferenceHeadViewItem.Component).EditText
              else if ReferenceHeadViewItem.Component is TcxDateEdit then
                FileName := FileName + '-' + TcxDateEdit(ReferenceHeadViewItem.Component).EditText
              else
                FileName := FileName + '-' + ReferenceHeadViewItem.Value;

     //TcxCustomEdit(viField.ReferenceViewItem.Component).EditValue
    ShowMessage(FileName);}
    if Execute then
    begin
      ExportGridToExcel(FileName, gridMain, true, true, true);
    end;
  end;


//   ExportGridToExcel('test', gridMain, true, true, true);
//  ExportGridToXLSX('test', gridDBMain, true, true, true);

end;

procedure TViewItemField.gridDBMainColumnPropertiesInitPopup(Sender: TObject);
var
  myForm: TfrmMetaControl;
begin

  myForm := TfrmMetaControl(Self.OwnerViewItem.Form);
  myForm.gridDBMain.BeginUpdate;
  with Self.ReferenceViewItem.DataSource.DataSet do
  begin
    Filtered := false;
    Filter := myForm.DParser(Self.ReferenceFilter);
    Filtered := true;
  end;

end;

procedure TViewItemField.gridDBMainColumnPropertiesCloseUp(Sender: TObject);
var
  myForm: TfrmMetaControl;
begin
  Self.ReferenceViewItem.DataSource.DataSet.Filtered := false;
  myForm := TfrmMetaControl(Self.OwnerViewItem.Form);
  myForm.gridDBMain.EndUpdate;
end;

function StreamToString(Stream: TStream): string;
var
  ms: TMemoryStream;
begin
  Result := '';
  ms := TMemoryStream.Create;
  try
    ms.LoadFromStream(Stream);
    SetString(Result, PChar(ms.memory), ms.Size);
  finally
    ms.free;
  end;
end;

procedure TfrmMetaControl.HTTP_POST(Url: string; Body: string);
var
  code: Integer;
  sResponse: string;
  BodyToSend: TStringStream;
  Stream: TMemoryStream;
  CTL, CTL2: TStringList;
  L, I: integer;
begin



//  Body := '{"Sample":{"ИП": "Петров", "Номер":"пд243", "Дата накладной":"23.10.2018",  "nameHeader":12}, "лис2т1": {"тест":213} }';
  HTTP1.HandleRedirects := true;
  HTTP1.Request.ContentType := 'application/json';
  HTTP1.Request.CharSet := 'utf-8';
  HTTP1.ReadTimeout := 15000;

  BodyToSend := TStringStream.Create(Utf8Encode(Body));

  Stream := TMemoryStream.Create;

  HTTP1.Post(Url, BodyToSend, Stream);

  CTL := TStringList.Create;
  CTL2 := TStringList.Create;
  CTL.Delimiter := ';';
  CTL.DelimitedText := HTTP1.Response.ContentDisposition;
  CTL2.Delimiter := '=';
  if CTL.Count >= 1 then
    CTL2.DelimitedText := CTL.Strings[1];

  if CTL.Find('attachment', I) then
    with dlgSaveXLS do
    begin
      //Excel 2007
      if HTTP1.Response.ContentType = 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet' then
      begin //Excel 2007
        Filter := 'All|*.*|Ecxel|*.xlsx;*.xls';
        DefaultExt := 'xlsx';
        FilterIndex := 2;
      end;
      if CTL2.count > 1 then
        FileName := CTL2.Strings[1];

      if Execute then
      begin
        Stream.SaveToFile(FileName);
      end;
    end
  else
    ShowMessage(StreamToString(Stream));

  Stream.Free;
  CTL.Free;
  CTL2.Free;
  BodyToSend.free;
end;

function TfrmMetaControl.AddFile_TemplateImport(Template: Integer): string;
var
  {определяем переменные для выполнения поставленной задачи}
  FileName: string; //имя файла :)
  response: string; //переменная для возращения HTML кода страницы
  formData: TIdMultiPartFormDataStream; //для передачи информации
  s: string;
  k: integer;
begin

  with dlgSaveXLS do
  begin
    begin //Excel 2007
      Filter := 'All|*.*|Ecxel|*.xlsx;*.xls';
      DefaultExt := 'xlsx';
      FilterIndex := 2;
    end;

    if Execute then
    begin
      FileName := dlgSaveXLS.Files[0];
      formData := TIdMultiPartFormDataStream.Create;
      Http1.Request.ContentType := formData.RequestContentType;
  {Передаем файл}
      formData.AddFile('file', FileName, 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet');
      formData.AddFormField('template', IntToStr(Template));

      s := 'http://triton.magic/cuteimport/upload/' + IntToStr(Template) + '/';

      begin
        response := HTTP1.Post(s, formData);

        result := response;
      end;
      formData.Free;

    end;
  end;
end;

procedure TfrmMetaControl.gridDBMainStylesGetContentStyle(Sender: TcxCustomGridTableView; ARecord: TcxCustomGridRecord; AItem: TcxCustomGridTableItem; out AStyle: TcxStyle);
var
  ColorField: string;
  ColumnID: integer;
  Cellvalue: variant;
  //AColumn, AColumnCheck: TcxCustomGridTableItem;
  i: Integer;
begin

  //AColumnCheck := (Sender as TcxGridDBBandedTableView).GetColumnByFieldName('ABC_style_lime');

  for i := 0 to MainViewItem.StyleList.Count - 1 do
    with (MainViewItem.StyleList[i] as TViewItemStyle) do
    begin
      //AColumn := (Sender as TcxGridDBBandedTableView).GetColumnByFieldName('ABC');
      if (Assigned(CheckColumn)) then
        if (ARecord.Values[CheckColumn.Index] = True) then
          if AItem = Column then
            AStyle := Style;

    end;
 { AColumn := (Sender as TcxGridDBBandedTableView).GetColumnByFieldName('ABC');
  if (Assigned(AColumnCheck)) then
    if (ARecord.Values[AColumnCheck.Index] = True) then
      if AItem = AColumn then
        AStyle := Style_lime;
  }
      {
  ColorField := MainViewItem.Fields.Find(TcxGridDBColumn(AViewInfo.Item).DataBinding.Fieldname).ColorField;
  if Assigned(gridDBMain.FindItemByName(ColorField)) and (not AViewInfo.Selected) and (ColorField <> '') then
  begin
    ARec := AViewInfo.Bounds;
    color := AViewInfo.GridRecord.Values[gridDBMain.FindItemByName(ColorField).Index];
    if color <> Null then
    begin
      ACanvas.brush.Color := color;
      ACanvas.Canvas.FillRect(ARec);
    end
  end;
       }
end;

procedure TfrmMetaControl.Button1Click(Sender: TObject);
var
  I: Integer;
  Index: Integer;
  APopupOwner: TcxGridColumnHeaderFilterButtonViewInfo;
begin

  Index := gridDBMain.Controller.FocusedColumn.VisibleIndex;

  with gridDBMain.ViewInfo.HeaderViewInfo[Index] do

    for I := 0 to AreaViewInfoCount - 1 do

      if AreaViewInfos[I] is TcxGridColumnHeaderFilterButtonViewInfo then
      begin

        APopupOwner := TcxGridColumnHeaderFilterButtonViewInfo(AreaViewInfos[I]);

        Break;

      end;

  gridDBMain.Controller.FilterPopup.Owner := APopupOwner;

  gridDBMain.Controller.FilterPopup.Popup;

end;

procedure TfrmMetaControl.Button2Click(Sender: TObject);
begin
  gridDBMain.Filtering.RunCustomizeDialog;

end;

end.

