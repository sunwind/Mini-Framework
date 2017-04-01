;{ License
/* This file is part of Mini-Framework For AutoHotkey.
 * 
 * Mini-Framework is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, version 2 of the License.
 * 
 * Mini-Framework is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with Mini-Framework.  If not, see <http://www.gnu.org/licenses/>.
 */
; End:License ;}
/*!
	Class: MfList
		MfList class exposes methods and properties used for common List and array type operations for strongly typed collections.
	Inherits:
		MfListBase
*/
class MfBinaryList extends MfListBase
{
	m_InnerList			:= Null
	m_Enum				:= Null
;{ Constructor
	/*!
		Constructor: ()
			Initializes a new instance of the MfList class.
	*/
	__new(Size=0, default=0) {
			base.__new()
			size := MfInteger.GetValue(size, 0)
			default := MfInteger.GetValue(default, 0)

			if ((Size > 0) && ((default = 0) || (default = 1)))
			{
				i := 0
				while (i <= size)
				{
					_newCount := i + 1
					this.m_InnerList[_newCount] := default
					i++
				}
				this.m_InnerList.Count := i
			}

		}
; End:Constructor ;}
;{ Methods
;{ 	Add()				- Overrides - MfListBase
/*
	Method: Add()
		Overrides MfListBase.Add()
		This method must be overridden in the derived class
	Add(obj)
		Adds an object to append at the end of the MfList
	Parameters
		obj
			The Object to locate in the MfList
	Returns
		Var containing Integer of the zero-based index at which the obj has been added.
	Throws
		Throws MfNullReferenceException if called as a static method.
*/
	Add(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 1)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "1"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_newCount := this.m_InnerList.Count + 1
		this.m_InnerList[_newCount] := _value
		this.m_InnerList.Count := _newCount
		retval := _newCount - 1
		return retval
	}
;	End:Add(value) ;}
;{ 	AddByte
	AddByte(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		
		MSB := 0
		LSB := 0

		if (_value > 0) 
		{
			MSB := _Value // 16
			LSB := Mod(_Value, 16)
			LsbHex := MfNibConverter._GetHexValue(LSB)
			MsbHex := MfNibConverter._GetHexValue(MSB)
			LsbInfo := MfNibConverter.HexBitTable[LsbHex]
			MsbInfo := MfNibConverter.HexBitTable[MsbHex]
			strBin := MsbInfo.Bin
			Loop, Parse, strBin
			{
				_newCount := this.m_InnerList.Count + 1
				this.m_InnerList[_newCount] := A_LoopField
				this.m_InnerList.Count := _newCount
			}
			strBin := LsbInfo.Bin
			Loop, Parse, strBin
			{
				_newCount := this.m_InnerList.Count + 1
				this.m_InnerList[_newCount] := A_LoopField
				this.m_InnerList.Count := _newCount
			}
		}
		else
		{
			i := 0
			while i < 8
			{
				_newCount := this.m_InnerList.Count + 1
				this.m_InnerList[_newCount] := 0
				this.m_InnerList.Count := _newCount
				i++
			}
		}
		
	}
; 	End:AddByte ;}
;{ 	AddNibble
	AddNibble(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 15)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "15"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MSB := 0
		LSB := 0

		if (_value > 0) 
		{
			Hex := MfNibConverter._GetHexValue(_value)
			Info := MfNibConverter.HexBitTable[Hex]
			strBin := Info.Bin
			Loop, Parse, strBin
			{
				_newCount := this.m_InnerList.Count + 1
				this.m_InnerList[_newCount] := A_LoopField
				this.m_InnerList.Count := _newCount
			}
		}
		else
		{
			i := 0
			while i < 4
			{
				_newCount := this.m_InnerList.Count + 1
				this.m_InnerList[_newCount] := 0
				this.m_InnerList.Count := _newCount
				i++
			}
		}
		
	}
; 	End:AddNibble ;}
;{ 	Clone
	Clone() {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		cLst := new MfBinaryList()
		cLst.Clear()
		for i, x in this
		{
			_newCount := i + 1
			cLst.m_InnerList[_newCount] := x
		}
		cLst.m_InnerList.Count := _newCount
		return cLst
	}
; 	End:Clone ;}
;{ 	Contains()			- Overrides - MfListBase
/*!
	Method: Contains()
		Overrides MfListBase.Contains()
	Contains(obj)
		Determines whether the MfList contains a specific element.
	Parameters
		obj
			The Object to locate in the MfList
		Returns
			Returns true if the MfList contains the specified value otherwise, false.
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	Contains(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		retval := false
		if (this.Count <= 0) {
			return retval
		}
		_value := MfInt16.GetValue(obj, -1)
		if ((_value < 0) || (_value > 1))
		{
			return retval
		}
		
		for i, b in this
		{
			if (b = _value)
			{
				retval := true
				break
			}
		}
		return retval
	}
;	End:Contains(obj) ;}


;{ 	IndexOf()			- Overrides - MfListBase
/*
	Method: IndexOf()
		Overrides MfListBase.IndexOf()
	IndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the first occurrence within the entire MfList.
	Parameters
		obj
			The object to locate in the MfList
	Returns
		Returns  index of the first occurrence of value within the entire MfList,
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	IndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		i := 0
		bFound := false
		int := -1
		if (this.Count <= 0) {
			return int
		}
		_value := MfInt16.GetValue(obj, -1)
		if (_value < 0 || _value > 1)
		{
			return int
		}
		for index, b in this.m_InnerList
		{
			if (b = _value)
			{
				bFound := true
				break
			}
			i++
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:IndexOf() ;}
;{ 	Insert()			- Overrides - MfListBase
/*!
	Method: Insert()
		Overrides MfListBase.Insert()
	Insert(index, obj)
		Inserts an element into the MfList at the specified index.
	Parameters
		index
			The zero-based index at which value should be inserted.
		obj
			The object to insert.
	Throws
		Throws MfNullReferenceException if called as a static method.
		Throws MfArgumentOutOfRangeException if index is less than zero.-or index is greater than MfList.Count
		Throws MfArgumentException if index is not a valid Integer object or valid var Integer.
		Throws MfNotSupportedException if MfList is read-only or Fixed size.
	Remarks
		If index is equal to Count, value is added to the end of MfGenericList.
		In MfList the elements that follow the insertion point move down to accommodate the new element.
		This method is an O(n) operation, where n is Count.
*/
	Insert(index, obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_index := MfInteger.GetValue(index)
		if (this.AutoIncrease = true)
		{
			While _index >= this.Count
			{
				this._AutoIncrease()
			}
		}
		if ((_index < 0) || (_index > this.Count))
		{
			ex := new MfArgumentOutOfRangeException("index", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_value := MfByte.GetValue(obj)
		if (_value < 0 || _value > 1)
		{
			ex := new MfArgumentOutOfRangeException("obj"
				, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
				, "0", "1"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (_index = this.Count)
		{
			this.Add(_value)
			return
		}
		i := _index + 1 ; step up to one based index for AutoHotkey array
		
		this.m_InnerList.InsertAt(i, _value)
		this.m_InnerList.Count ++
	}
;	End:Insert(index, obj) ;}
;{ 	LastIndexOf()
/*
	Method: LastIndexOf()

	LastIndexOf(obj)
		Searches for the specified Object and returns the zero-based index of the Lasst occurrence within the entire List.
	Parameters
		obj
			The object to locate in the List
	Returns
		Returns  index of the last occurrence of value within the entire List,
	Throws
		Throws MfNullReferenceException if called as a static method.
	Remarks
		This method performs a linear search; therefore, this method is an O(n) operation, where n is Count.
		This method determines equality by calling MfObject.CompareTo().
*/
	LastIndexOf(obj) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		i := 0
		bFound := false
		int := -1
		if (this.Count <= 0) {
			return int
		}
		_value := MfInt16.GetValue(obj, -1)
		if (_value < 0 || _value > 1)
		{
			return int
		}
		i := this.Count - 1
		while (i >= 0)
		{
			b := this.Item[i]
			if (b = _value)
			{
				bFound := true
				break
			}
			i--
		}
		if (bFound = true) {
			int := i
			return int
		}
		return int
	}
;	End:LastIndexOf() ;}
;{ 	ToString
	ToString(returnAsObj = false, startIndex = 0, length="", Format=0) {
		this.VerifyIsInstance(this, A_LineFile, A_LineNumber, A_ThisFunc)
		
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_Format := MfInteger.GetValue(Format, false)
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(length)) {
			_length := this.Count - _startIndex
		}
		else
		{
			_length := MfInteger.GetValue(length)
		}
		if (_length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > (this.Count - _length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_Format = 1)
		{
			return this._ToByteArrayString(_returnAsObj, _startIndex, _length)
		}
		retval := ""
		i := _startIndex
		iMaxIndex := _length - 1
		while i <= iMaxIndex
		{
			n := this.Item[i]
			hexChar := MfBitConverter._GetHexValue(n)
			retval .= hexChar
			i++
		}
		
		return _returnAsObj = true?new MfString(retval):retval
	}
; 	End:ToString ;}
;{ 		SubList
	; The SubList() method extracts the elements from list, between two specified indices, and returns the a new list.
	; This method extracts the element in a list between "startIndex" and "endIndex", not including "endIndex" itself.
	; If "startIndex" is greater than "endIndex", this method will swap the two arguments, meaning lst.SubList(1, 4) == lst.SubList(4, 1).
	; If either "startIndex" or "endIndex" is less than 0, it is treated as if it were 0.
	; startIndex and endIndex mimic javascript substring
	; Params
	;	startIndex
	;		The position where to start the extraction. First element is at index 0
	;	endIndex
	;		The position (up to, but not including) where to end the extraction. If omitted, it extracts the rest of the list
	SubList(startIndex=0, endIndex="") {
		startIndex := MfInteger.GetValue(startIndex, 0)
		endIndex := MfInteger.GetValue(endIndex, "NaN", true)
		maxIndex := this.Count - 1
		IsEndIndex := true
		if (endIndex == "NaN")
		{
			IsEndIndex := False
		}
		If (IsEndIndex = true && endIndex < 0)
		{
			endIndex := 0
		}
		if (startIndex < 0)
		{
			startIndex := 0
		}
		if ((IsEndIndex = false) && (startIndex = 0))
		{
			Return this
		}
		if ((IsEndIndex = false) && (startIndex > maxIndex))
		{
			Return this
		}
		if ((IsEndIndex = true) && (startIndex > endIndex))
		{
			; swap values
			tmp := startIndex
			startIndex := endIndex
			endIndex := tmp
		}
		if ((IsEndIndex = true) && (endIndex = startIndex))
		{
			return this
		}
		if (startIndex > maxIndex)
		{
			return this
		}
		if (IsEndIndex = true)
		{
			len :=  endIndex - startIndex
			if ((len + 1) >= this.Count)
			{
				return this
			}
		}
		else
		{
			len := maxIndex
		}
		rLst := new MfBinaryList()
		rl := rLst.m_InnerList

		i := 1
		iCount := 0
		if (IsEndIndex = true)
		{
			While ((iCount + len) < (this.Count - 1))
			{
				iCount++
			}
		}
		else
		{
			While ((iCount + (len - startIndex)) < (this.Count - 1))
			{
				iCount++
			}
		}
			
		ll := this.m_InnerList
		while iCount < ll.Count
		{
			iCount++
			;lst.Add(this.Item[i])
			rl[i] := ll[iCount]
			i++
			
		}
		rl.Count := i - 1
		return rLst

	}
; 		End:SubList ;}
	_ToByteArrayString(returnAsObj, startIndex, length) {
		retval := ""
		i := startIndex
		iMaxIndex := length -1
		len := iMaxIndex - startIndex
		iChunk := 0
		rem := Mod(this.Count, 4)
		iCount := 0
		if (rem > 0)
		{
			offset := (4 - rem)
			k := 0
			While k <= offset
			{
				retval .= "0"
				k++
			}
			iCount := offset
			;i += offset
		}
		iLoopCount := 0
		while i <= iMaxIndex
		{
			if (iLoopCount > 0)
			{
				retval .= "-"
			}
			while iCount < 4
			{
				if (i > iMaxIndex)
				{
					break
				}
				retval .= this.Item[i]
				iCount++
				i++
			}
			
			iLoopCount++
			iCount := 0
			
		}
		
		return returnAsObj = true?new MfString(retval):retval
	}
	_AutoIncrease()
	{
		if (this.IsFixedSize) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_FixedSize"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (this.IsReadOnly) {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_List"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		If (this.Count < 1)
		{
			this.Add(0)
			return
		}
		NewCount := this.Count * 2
		while this.Count < NewCount
		{
			this.Add(0)
		}
	}
; End:Methods ;}
;{ Properties
	m_AutoIncrease := false
;{	AutoIncrease[]
/*
	Property: AutoIncrease [get]
		Gets a value indicating the list should Auto-Increase in size when Limit is reached
	Value:
		Var Bool
	Remarks"
		Gets/Sets if the List will auto increase when limit is reached.
*/
	AutoIncrease[]
	{
		get {
			return this.m_AutoIncrease
		}
		set {
			this.m_AutoIncrease := MfBool.GetValue(Value)
		}
	}
;	End:AutoIncrease[] ;}
;{	Count[]
/*
	Property: Count [get]
		Overrides MfListBase.Count
		Gets a value indicating count of objects in the current MfList as an Integer
	Value:
		Var Integer
	Gets:
		Gets the count of elements in the MfList as var integer.
	Remarks"
		Read-only property.
*/
	Count[]
	{
		get {
			return this.m_InnerList.Count
		}
		set {
			ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			Throw ex
		}
	}
;	End:Count[] ;}
;{	Item[index]
/*
	Property: Item [get\set]
		Overrides MfListBase.Item
		Gets or sets the element at the specified index.
	Parameters:
		index
			The zero-based index of the element to get or set.
		value
			the value of the item at the specified index
	Gets:
		Gets element at the specified index.
	Sets:
		Sets the element at the specified index
	Throws:
		Throws MfArgumentOutOfRangeException if index is less than zero or index is equal to or greater than Count
		Throws MfArgumentException if index is not a valid MfInteger instance or valid var containing Integer
*/
	Item[index]
	{
		get {
			_index := MfInteger.GetValue(Index)
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_index ++ ; increase value for one based array
			return this.m_InnerList[_index]
		}
		set {
			_index := MfInteger.GetValue(Index)
			
			if (_index < 0) {
				ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			if (_index >= this.Count)
			{
				if (this.AutoIncrease = true)
				{
					While _index >= this.Count
					{
						this._AutoIncrease()
					}
				}
				else
				{
					ex := new MfArgumentOutOfRangeException(MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Index"))
					ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
					throw ex
				}
			}
			_value := MfByte.GetValue(value)
			if (_value < 0 || _value > 1)
			{
				ex := new MfArgumentOutOfRangeException("value"
					, MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_Bounds_Lower_Upper" 
					, "0", "1"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			_index ++ ; increase value for one based array
			this.m_InnerList[_index] := _value
			return this.m_InnerList[_index]
		}
	}
;	End:Item[index] ;}
; End:Properties ;}
}
/*!
	End of class
*/