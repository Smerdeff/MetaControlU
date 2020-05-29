unit helperU;

interface

uses
  Classes, DB, ADODB, Variants, cxGrid, cxGridDBTableView, FR_Pars, forms, cxGridTableView, cxGridCustomTableView, StrUtils;

type
  CHelper = class
//    FParser: TfrParser;
    class function SearchIncxGrid(AView: TcxGridTableView; AText: string; AFromBeginning: boolean): boolean;

    class function SplitString(Str, Delimiter: string): TStringList;
    class function GetSelectedString_semicolon(grid: TcxGridTableView; index: Integer): string;
    class function GetSelectedString(grid: TcxGridTableView; index: Integer): string;
    class procedure refreshDataSet(DataSet: TCustomADODataSet);
    class procedure copyRecords(TableName: string; Where: string);
    class function GetErrorMessage(ObjectName: string; ErrorMessageID: Integer): string;
    class function TableDatasetOpen(Sender: TComponent; TableName: string; sa:Boolean=False): TADODataSet;
    class function spExecute(ExecSQL: string; sa:Boolean=False): integer; overload;
    class function spExecute(spName: string; param1: variant; sa:Boolean=False): integer; overload;
    class function spExecute(spName: string; param1: Variant; param2: variant; sa:Boolean=False): integer; overload;
    class function spExecute(spName: string; param1: variant; param2: variant; param3: variant; sa:Boolean=False): integer; overload;
    class function spExecute(spName: string; param1: variant; param2: variant; param3: variant; param4: variant; sa:Boolean=False): integer; overload;
    class function spExecute(spName: string; param1: variant; param2: variant; param3: variant; param4: variant; param5: variant; sa:Boolean=False): integer; overload;
    class function spDatasetOpen(Sender: TComponent; spName: string; sa:Boolean=False): TADODataSet; overload;
    class function spDatasetOpen(Sender: TComponent; spName: string; param1: variant; sa:Boolean=False): TADODataSet; overload;
    class function spDatasetOpen(Sender: TComponent; spName: string; param1: Variant; param2: variant; sa:Boolean=False): TADODataSet; overload;
    class function spDatasetOpen(Sender: TComponent; spName: string; param1: variant; param2: variant; param3: variant; sa:Boolean=False): TADODataSet; overload;
//   class function spDatasetOpen(Sender: TComponent; spName:string; param1:variant; param2:variant; param3:variant; param4:variant):TADODataSet; overload;
//   class function spDatasetOpen(Sender: TComponent; spName:string; param1:variant; param2:variant; param3:variant; param4:variant; param5:variant):TADODataSet; overload;

//    class function CreateView(Sender: TComponent; Name: string; Caption: string): TADODataSet; overload;
  end;

implementation

uses
  dmMainU, Math, SysUtils;



class function CHelper.GetErrorMessage(ObjectName: string; ErrorMessageID: Integer): string;
begin
  if not dmMain.adoErrorMessages.Active then
    dmMain.adoErrorMessages.open;

  Result := VarToStr(dmMain.adoErrorMessages.Lookup('ObjectName;ErrorMessageID', VarArrayOf([ObjectName, ErrorMessageID]), 'ru_RU'));

end;

class function CHelper.SplitString(Str, Delimiter: string): TStringList;
var
  i, j, l: integer;
begin
  Result := TStringList.Create;
  l := Length(Delimiter);
  j := 1;
  for i := 1 to Length(Str) - l do
  begin
    if AnsiCompareText(copy(Str, i, l), Delimiter) = 0 then
    begin
      Result.Add(copy(Str, j, i - j));
      j := i + l;
    end;
  end;
  Result.Add(copy(Str, j, Length(Str)));
end;

class function CHelper.TableDatasetOpen(Sender: TComponent; TableName: string; sa:Boolean=False): TADODataSet;
var
  adoDataSet: TADODataSet;
begin
  adoDataSet := TADODataSet.Create(Sender);
  If sa
    then adoDataSet.Connection := dmMain.Main_ADOConnectionSA
    else adoDataSet.Connection := dmMain.Main_ADOConnection;
  adoDataSet.CommandType := cmdTable;
  adoDataSet.CommandText := TableName;
  adoDataSet.Open;
  Result := adoDataSet;
end;

class function CHelper.spDatasetOpen(Sender: TComponent; spName: string; sa:Boolean=False): TADODataSet;
var
  adoDataSet: TADODataSet;
begin
  adoDataSet := TADODataSet.Create(Sender);
  If sa
    then adoDataSet.Connection := dmMain.Main_ADOConnectionSA
    else adoDataSet.Connection := dmMain.Main_ADOConnection;
  adoDataSet.CommandType := cmdStoredProc;
  adoDataSet.CommandText := spName;
  adoDataSet.Parameters.Refresh;
  adoDataSet.Open;
  Result := adoDataSet;
end;

class function CHelper.spDatasetOpen(Sender: TComponent; spName: string; param1: variant; sa:Boolean=False): TADODataSet;
var
  adoDataSet: TADODataSet;
begin
  adoDataSet := TADODataSet.Create(Sender);
  If sa
    then adoDataSet.Connection := dmMain.Main_ADOConnectionSA
    else adoDataSet.Connection := dmMain.Main_ADOConnection;
  adoDataSet.CommandType := cmdStoredProc;
  adoDataSet.CommandText := spName;
  adoDataSet.Parameters.Refresh;
  adoDataSet.Parameters.Items[1].Value := param1;
  adoDataSet.Open;
  Result := adoDataSet;
end;

class function CHelper.spDatasetOpen(Sender: TComponent; spName: string; param1: variant; param2: variant; sa:Boolean=False): TADODataSet;
var
  adoDataSet: TADODataSet;
begin
  adoDataSet := TADODataSet.Create(Sender);
  If sa
    then adoDataSet.Connection := dmMain.Main_ADOConnectionSA
    else adoDataSet.Connection := dmMain.Main_ADOConnection;
  adoDataSet.CommandType := cmdStoredProc;
  adoDataSet.CommandText := spName;
  adoDataSet.Parameters.Refresh;
  adoDataSet.Parameters.Items[1].Value := param1;
  adoDataSet.Parameters.Items[2].Value := param2;
  adoDataSet.Open;
  Result := adoDataSet;
end;

class function CHelper.spDatasetOpen(Sender: TComponent; spName: string; param1: variant; param2: variant; param3: variant; sa:Boolean=False): TADODataSet;
var
  adoDataSet: TADODataSet;
begin
  adoDataSet := TADODataSet.Create(Sender);
  If sa
    then adoDataSet.Connection := dmMain.Main_ADOConnectionSA
    else adoDataSet.Connection := dmMain.Main_ADOConnection;
  adoDataSet.CommandType := cmdStoredProc;
  adoDataSet.CommandText := spName;
  adoDataSet.Parameters.Refresh;
  adoDataSet.Parameters.Items[1].Value := param1;
  adoDataSet.Parameters.Items[2].Value := param2;
  adoDataSet.Parameters.Items[3].Value := param3;
  adoDataSet.Open;
  Result := adoDataSet;
end;

class function CHelper.spExecute(ExecSQL: string; sa:Boolean=False): integer;
begin
  with dmMain.adoExecQuery do
  begin
    If sa
      then Connection := dmMain.Main_ADOConnectionSA
      else Connection := dmMain.Main_ADOConnection;
    CommandText := ExecSQL;
    Execute;

  end;
end;

class function CHelper.spExecute(spName: string; param1: variant; sa:Boolean=False): integer;
begin
  with dmMain.adoSPExec do
  begin
    If sa
      then Connection := dmMain.Main_ADOConnectionSA
      else Connection := dmMain.Main_ADOConnection;
    ProcedureName := spName;
    Parameters.Refresh;
    if Parameters.Items[1].DataType = ftVarBytes then
      Parameters.Items[1].DataType := ftBlob;
    Parameters.Items[1].Value := param1;
    ExecProc;
    result := Parameters.Items[0].Value;
  end;
end;

class function CHelper.spExecute(spName: string; param1: variant; param2: variant; sa:Boolean=False): integer;
begin
  with dmMain.adoSPExec do
  begin
    If sa
      then Connection := dmMain.Main_ADOConnectionSA
      else Connection := dmMain.Main_ADOConnection;

    ProcedureName := spName;
    Parameters.Refresh;
    if Parameters.Items[1].DataType = ftVarBytes then
      Parameters.Items[1].DataType := ftBlob;
    Parameters.Items[1].Value := param1;
    Parameters.Items[2].Value := param2;
    ExecProc;
    result := Parameters.Items[0].Value;
  end;

end;

class function CHelper.spExecute(spName: string; param1: variant; param2: variant; param3: variant; sa:Boolean=False): integer;
begin
  with dmMain.adoSPExec do
  begin
    If sa
      then Connection := dmMain.Main_ADOConnectionSA
      else Connection := dmMain.Main_ADOConnection;
    ProcedureName := spName;
    Parameters.Refresh;
    if Parameters.Items[1].DataType = ftVarBytes then
      Parameters.Items[1].DataType := ftBlob;
    Parameters.Items[1].Value := param1;
    Parameters.Items[2].Value := param2;
    Parameters.Items[3].Value := param3;
    ExecProc;
    result := Parameters.Items[0].Value;
  end;
end;

class function CHelper.spExecute(spName: string; param1: variant; param2: variant; param3: variant; param4: variant; sa:Boolean=False): integer;
begin
  with dmMain.adoSPExec do
  begin
    If sa
      then Connection := dmMain.Main_ADOConnectionSA
      else Connection := dmMain.Main_ADOConnection;
    ProcedureName := spName;
    Parameters.Refresh;
    Parameters.Items[1].Value := param1;
    Parameters.Items[2].Value := param2;
    Parameters.Items[3].Value := param3;
    Parameters.Items[4].Value := param4;
    ExecProc;
    result := Parameters.Items[0].Value;
  end;
end;

class function CHelper.spExecute(spName: string; param1: variant; param2: variant; param3: variant; param4: variant; param5: variant; sa:Boolean=False): integer;
begin
  with dmMain.adoSPExec do
  begin
    If sa
      then Connection := dmMain.Main_ADOConnectionSA
      else Connection := dmMain.Main_ADOConnection;
    ProcedureName := spName;
    Parameters.Refresh;
    Parameters.Items[1].Value := param1;
    Parameters.Items[2].Value := param2;
    Parameters.Items[3].Value := param3;
    Parameters.Items[4].Value := param4;
    Parameters.Items[5].Value := param5;
    ExecProc;
    result := Parameters.Items[0].Value;
  end;
end;

class procedure CHelper.refreshDataSet(DataSet: TCustomADODataSet);
var
  b: TBookmark;
begin
  with DataSet do
  begin
    try
      b := GetBookmark;
      DisableControls;
      Close;
      Open;
      if recordCount > 0 then
        if {recordCount>0} BookMarkValid(b) then
          GotoBookmark(b);
    finally
      EnableControls;
    end;
  end

end;

class procedure CHelper.copyRecords(TableName: string; Where: string);
begin
  spExecute('spCopyRecords', TableName, Where)
end;


class function CHelper.GetSelectedString_semicolon(grid: TcxGridTableView; index: Integer): string;
var
  BSelectedString: string;
  i, v: integer;
begin

  BSelectedString := '';
  try
    TcxGridDBTableView(grid).DataController.DataSource.DataSet.DisableControls;

    //SetLength(BSelectedString, grid.Controller.SelectedRowCount * 4);
    for i := 0 to grid.Controller.SelectedRowCount - 1 do
    begin
      BSelectedString:=BSelectedString+VarToStr(grid.Controller.SelectedRows[i].Values[index])+';'
      //v := grid.Controller.SelectedRows[i].Values[index];
      //PInteger(@BSelectedString[i * 4 + 1])^ := v;
    end;
  finally
    TcxGridDBTableView(grid).DataController.DataSource.DataSet.EnableControls;
  end;
  result := BSelectedString;

end;


class function CHelper.GetSelectedString(grid: TcxGridTableView; index: Integer): string;
var
  BSelectedString: string;
  i, v: integer;
begin

  BSelectedString := '';
  try
    TcxGridDBTableView(grid).DataController.DataSource.DataSet.DisableControls;

    SetLength(BSelectedString, grid.Controller.SelectedRowCount * 4);
    for i := 0 to grid.Controller.SelectedRowCount - 1 do
    begin
      v := grid.Controller.SelectedRows[i].Values[index];
      PInteger(@BSelectedString[i * 4 + 1])^ := v;
    end;
  finally
    TcxGridDBTableView(grid).DataController.DataSource.DataSet.EnableControls;
  end;
  result := BSelectedString;

end;

class function CHelper.SearchIncxGrid(AView: TcxGridTableView; AText: string; AFromBeginning: boolean): boolean;
//const
//  MsgDataNotFound = 'Данные, удовлетворяющие условию поиска, не обнаружены';

var
  GroupsIndex: integer;
  GroupsCount: integer;
  ChildCount: integer;
  ColIndex: integer;
  RowIndex: integer;
  RecIndex: integer;
  CurIndex: integer;
  i, j, k: integer;
function
  Compare(ARecIndex, AColIndex: integer): boolean;
  begin
    Result :=
      AnsiContainsText
      (
        AView.DataController.DisplayTexts
        [
          ARecIndex,
          AView.VisibleColumns[AColIndex].Index
        ],
        AText
      );
  end;
begin
  Result := false;
  AView.DataController.ClearSelection;

  if AFromBeginning then
  begin
    // поиск с начала
    // строка  - первая
    // столбец - первый
    RowIndex := 0;
    ColIndex := 0;
  end
  else
  begin
    // поиск с текущей позиции
    // строка  - текущая
    // столбец - слещующий после текущего
    // если текущий столбец последний, то начинаем поиск
    // с первого столбца следующей строки
    RowIndex := AView.Controller.FocusedRowIndex;
    ColIndex := AView.Controller.FocusedColumnIndex;
    if AView.Controller.FocusedColumn.IsLast then
    begin
      ColIndex := 0;
      Inc(RowIndex);
    end
    else
      Inc(ColIndex)
  end;

  if AView.DataController.Groups.GroupingItemCount = 0 then
  begin
    // поиск в несгруппированном представлении
    for i := RowIndex to AView.ViewData.RowCount - 1 do
    begin
      //RecIndex := AView.ViewData.Rows[i].RecordIndex;
      RecIndex := AView.ViewData.Rows[i].RecordIndex;
      //RecIndex := i;
      if RecIndex = -1 then
        Continue;

      for j := ColIndex to AView.VisibleColumnCount - 1 do
      begin
        Result := Compare(RecIndex, j);
        if Result then
        begin
          AView.Controller.FocusedRecordIndex := i;
          //AView.ViewData.Rows[i].Index
          AView.Controller.FocusedColumnIndex := j;
          Break;
        end;
      end;

      ColIndex := 0;
      if Result then
        Break;
    end;
  end
  else
  begin
{    // поиск в сгруппированном представлении
    GroupsCount := TcxDataControllerGroupsProtected(AView.DataController.Groups).DataGroups.Count;
    GroupsIndex := AView.DataController.Groups.DataGroupIndexByRowIndex[RowIndex];
    for i := GroupsIndex to GroupsCount - 1 do
    begin
      ChildCount := AView.DataController.Groups.ChildCount[i];
      for j := 0 to ChildCount - 1 do
      begin
        RecIndex := AView.DataController.Groups.ChildRecordIndex[i, j];
        if RecIndex = -1 then
          Continue;

        CurIndex := AView.DataController.GetRowIndexByRecordIndex(RecIndex, false);
        if (CurIndex > -1) and (CurIndex < RowIndex) then
          Continue;

        for k := ColIndex to AView.VisibleColumnCount - 1 do
        begin
          Result := Compare(RecIndex, k);
          if Result then
          begin
            AView.Controller.FocusedRowIndex     := AView.DataController.GetRowIndexByRecordIndex(RecIndex, true);
            AView.Controller.FocusedColumnIndex := k;
            Break;
          end;
        end;

        ColIndex := 0;
        if Result then
          Break;
      end;

      if Result then  Break;
    end;
}
  end;

  if Result then
    AView.Controller.FocusedRecord.Selected := true;
end;


end.

