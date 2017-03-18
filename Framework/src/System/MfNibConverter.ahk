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
class MfNibConverter extends MfObject
{

;{ Methods
;{ 	GetNibbles
	GetNibbles(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!IsObject(obj))
		{
			IsNeg := False
			if(MfMath._IsStringInt(obj, IsNeg))
			{
				return MfNibConverter._LongIntStringToHexArray(obj, 0)
			}
		}
		
		wf := A_FormatInteger
		Try
		{
			SetFormat, IntegerFast, d
			if (MfObject.IsObjInstance(obj, MfBool))
			{
				if (obj.Value = true)
				{
					return MfNibConverter._GetBytesInt(1, 8, true)
				}
				return MfNibConverter._GetBytesInt(0, 8, true)
			}
			else if (MfObject.IsObjInstance(obj, MfChar))
			{
				return MfNibConverter._GetBytesInt(obj.CharCode, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInt16))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInteger))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 32)
			}
			else if (MfObject.IsObjInstance(obj, MfInt64))
			{
				return MfNibConverter._GetBytesInt(obj.Value, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				return MfNibConverter._GetBytesUInt(obj.Value, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfFloat))
			{
				int := MfBitConverter._FloatToInt64(obj.Value)
				return MfNibConverter._GetBytesInt(int, 64)
			}
		}
		Catch e
		{
			ex := new MfException(MfEnvironment.Instance.GetResourceString("Exception_Error", A_ThisFunc), e)
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		finally
		{
			SetFormat, IntegerFast, %ws%
		}
			

		ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_MethodOverload", A_ThisFunc))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		throw ex
	}
; 	End:GetNibbles ;}
;{ 	ToIntegerString
	ToIntegerString(nibbles, starIndex=-1) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := 0 ; _HexToDecimal loops index forward
		}
		if ((_startIndex < 0) || (_startIndex >= nibbles.Count))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfNibConverter._HexToDecimal(nibbles, _startIndex)
	}
; 	End:ToIntegerString ;}
	
;{ 	CompareUnsignedList
	CompareUnsignedList(objA, objB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfNibConverter._CompareUnSignedIntegerArraysBe(objA, objB)
	}
; 	End:CompareUnsignedList ;}
;{ 	CompareSignedList
	CompareSignedList(objA, objB)	{
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		HexA := MfBitConverter._GetHexValue(objA.Item[0])
		MostSigbitInfoA :=  MfNibConverter.HexBitTable[HexA]
		
		HexB := MfBitConverter._GetHexValue(objA.Item[0])
		MostSigbitInfoB :=  MfNibConverter.HexBitTable[HexB]
		if ((MostSigbitInfoA.IsNeg = true) && (MostSigbitInfoB.IsNeg = false))
		{
			return -1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = true))
		{
			return 1
		}
		if ((MostSigbitInfoA.IsNeg = false) && (MostSigbitInfoB.IsNeg = false))
		{
			return MfNibConverter._CompareUnSignedIntegerArraysBe(objA, objB)
		}
		if (MostSigbitInfoA.IsNeg = true)
		{
			ObjA := MfBitConverter._FlipNibbles(ObjA)
		}
		if (MostSigbitInfoB.IsNeg = true)
		{
			ObjB := MfBitConverter._FlipNibbles(ObjB)
		}
		result := MfNibConverter._CompareUnSignedIntegerArraysBe(objA, objB)
		if (result > 0)
		{
			return -1
		}
		if (result < 0)
		{
			return 1
		}
		return result
	}
; 	End:CompareSignedList ;}
;{ 	FromByteList
	; converts from MfByteList to MfNibbleList
	FromByteList(bytes, startIndex=0) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		lst := new MfNibbleList()
		if (bytes.Count = 0)
		{
			return lst
		}
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= bytes.Count)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		i := (bytes.Count - _startIndex) - 1
		while i >= 0
		{
			b := bytes.Item[i]
			lst.AddByte(b)
			i--
		}
		return lst
	}

; 	End:FromByteList ;}
;{ 	ToBool
	ToBool(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := nibbles.Count - 1
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (nibbles.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := nibbles.Item[_startIndex] != 0
		if (_ReturnAsObj)
			return new MfBool(retval)
		return retval

	}
; 	End:ToBool ;}
;{ 	ToByte
	ToByte(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 2 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, -1)
		
		MaxStartIndex := nibbles.Count - nCount
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MSB := nibbles.Item[_startIndex]

		LSB := nibbles.Item[_startIndex + 1]

		retval := (MSB * 16) + LSB
		if ((retval < MfByte.MinValue) || (retval > MfByte.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Byte"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfByte(retval)
		}

		return retval

	}
; 	End:ToByte ;}
;{ ToChar
	ToChar(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := MfNibConverter.ToInt16(nibbles, startIndex, false)
		c := new MfChar(result)
		c.CharCode := result
		if (_ReturnAsObj)
		{
			return c
		}
		return c.Value
	}
; End:ToChar ;}
;{ ToInt16
	ToInt16(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 4 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := ""
		iCount := 0
		i := _startIndex
		IsNeg := false
		while iCount < nCount
		{
			HexKey := MfNibConverter._GetHexValue(nibbles.Item[i])
			if (iCount = 0)
			{
				bInfo := MfNibConverter.HexBitTable[HexKey]
				IsNeg := bInfo.IsNeg
			}
			retval .= MfNibConverter._GetHexValue(nibbles.Item[i])
			iCount++
			i++
		}
		if (IsNeg)
		{
			negVal := ""
			Loop, Parse, retval
			{
				bInfo := MfNibConverter.HexBitTable[A_LoopField]
				negVal .= bInfo.HexFlip
			}
			retval := "-0x" . negVal
			retval := retval - 0x1
		}
		else
		{
			retval := "0x" . retval
			retval := retval + 0x0
		}
		if ((retval < MfInt16.MinValue) || (retval > MfInt16.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int16"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInt16(retval)
		}
		return retval
	}
; End:ToInt16 ;}
;{ 	ToInt32
	ToInt32(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 8 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := ""
		iCount := 0
		i := _startIndex
		IsNeg := false
		while iCount < nCount
		{
			HexKey := MfNibConverter._GetHexValue(nibbles.Item[i])
			if (iCount = 0)
			{
				bInfo := MfNibConverter.HexBitTable[HexKey]
				IsNeg := bInfo.IsNeg
			}
			retval .= MfNibConverter._GetHexValue(nibbles.Item[i])
			iCount++
			i++
		}
		if (IsNeg)
		{
			negVal := ""
			Loop, Parse, retval
			{
				bInfo := MfNibConverter.HexBitTable[A_LoopField]
				negVal .= bInfo.HexFlip
			}
			retval := "-0x" . negVal
			retval := retval - 0x1
		}
		else
		{
			retval := "0x" . retval
			retval := retval + 0x0
		}
		if ((retval < MfInteger.MinValue) || (retval > MfInteger.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfInteger(retval)
		}
		return retval
	}
; 	End:ToInt32 ;}
;{ 	ToInt64
	ToInt64(nibbles, startIndex = -1, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nibbles, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nCount := 16 ; Number of nibbles needed for conversion
		if (nibbles.Count < nCount)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		MaxStartIndex := nibbles.Count - nCount
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := MaxStartIndex
		}
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > MaxStartIndex))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := ""
		iCount := 0
		i := _startIndex
		IsNeg := false
		while iCount < nCount
		{
			HexKey := MfNibConverter._GetHexValue(nibbles.Item[i])
			if (iCount = 0)
			{
				bInfo := MfNibConverter.HexBitTable[HexKey]
				IsNeg := bInfo.IsNeg
			}
			retval .= MfNibConverter._GetHexValue(nibbles.Item[i])
			iCount++
			i++
		}
		if (IsNeg)
		{
			; due to Int64 Minvalue being the smallest valid int will have to convert to Nibbles to
			; do a valid check if minvalue is within range
			negVal := new MfNibbleList()
			Loop, Parse, retval
			{
				bInfo := MfNibConverter.HexBitTable[A_LoopField]
				bFlip := MfNibConverter.HexBitTable[bInfo.HexFlip]
				negVal.Add(bFlip.IntValue)
			}
			MfNibConverter._AddOneToNibListValue(negVal)

			retval := "-0x" . negVal.ToString()
			if (MfMath._IsValidInt64Range(retval) = false)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := retval + 0x0
		}
		else
		{
			retval := "0x" . retval
			if (MfMath._IsValidInt64Range(retval) = false)
			{
				ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_Int64"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			retval := retval + 0x0
		}
		
		if (_ReturnAsObj)
		{
			return new MfInt64(retval)
		}
		return retval
	}
; 	End:ToInt64 ;}
;{ 	ToByteList
	ToByteList(nList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nList, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(nList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		lst := new MfByteList()
		
		iMaxIndex := nList.Count - 1
		i := iMaxIndex
		;~ if (this.Count & 1) ; if uneven count
		;~ {
			;~ n := this.Item[this.Count -1]
			;~ ;n := this.Item[0]
			;~ lst.Add(n)
			;~ i--
		;~ }
		while i >= 0
		{
			j := i - 1
			LSB := nList.Item[i]
			if (j >= 0)
			{
				MSB := nList.Item[j]
				Value := (MSB * 16) + LSB
				lst.Add(Value)
			}
			
			i -= 2
		}
		if (nList.Count & 1) ; if uneven count
		{
			;n := this.Item[this.Count -1]
			n := nList.Item[0]
			lst.Add(n)
			i--
		}
		
		return lst
	}
; 	End:ToByteList ;}
;{ NibbleListsAdd
	NibbleListAdd(ListA, ListB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(ListA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(ListB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (ListA.Count > ListB.Count)
		{
			return MfNibConverter._NibListsAdd(ListA, ListB)
		}
		return MfNibConverter._NibListsAdd(ListB, ListA)
		
	}
; End:NibbleListsAdd ;}
	NibbleListMultiply(ListA, ListB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(ListA, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(ListB, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(ListB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "ListB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Compare := MfNibConverter.CompareSignedNibbleArrays(ListA, ListB)
		if (Compare > 0)
		{
			return MfNibConverter._MultiplyNibList(ListA, ListB)
		}
		return MfNibConverter._MultiplyNibList(ListA, ListB)
	}
;{ 	NibbleListToComplementTwo
	ToComplementTwo(nList) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(nList, MfNibbleList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if(nList.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "nList"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := MfNibConverter._FlipNibbles(nList)
		MfNibConverter._AddOneToNibListValue(retval)
		return retval
	}
;{ 	NibbleListToComplementTwo
; End:Methods ;}
;{ Internal Methods
;{ 	_AddOneToNibList
	; adds one to the value of lst only if there
	; is no carry.
	; returns true is value of one was added otherwise false
	; If AddToFront is true then value is added at the beginning Of
	; the list otherwise at the end of the list.
	_AddOneToNibList(byref lst, AddToFront=true) {
		IsAdded := false
		if (lst.Count & 1)
		{
			return false
		}
		if ( AddToFront = true)
		{
			i := 0
			While i < lst.Count
			{
				j := i + 1
				Lsb := lst.Item[j]
				Msb := lst.Item[i]
				if (Lsb < 15)
				{
					Lsb++
					lst.Item[j] := Lsb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[j] := 0
				}
				
				if (Msb < 15)
				{
					Msb++
					lst.Item[i] := Msb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[i] := 0
				}
				i += 2
			}
		}
		else
		{
			i := lst.Count - 1
			While i >= 0
			{
				j := i - 1
				Lsb := lst.Item[i]
				Msb := lst.Item[j]
				if (Lsb < 15)
				{
					Lsb++
					lst.Item[i] := Lsb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[i] := 0
				}
				if (Msb < 15)
				{
					Msb++
					lst.Item[j] := Msb
					IsAdded := true
					break
				}
				else
				{
					lst.Item[j] := 0
				}
				i -= 2
			}
		}
		return IsAdded
	}
; 	End:_AddOneToNibList ;}
;{ 	_AddOneToNibListValue
	; adds 1 to the summ of lst
	; param lst instance of MfNibbleList
	_AddOneToNibListValue(byref lst) {
		iCarry := 1
		i := lst.Count - 1
		while i >= 0
		{
			sum := (lst.Item[i] + 1)
			if (sum > 15)
			{
				lst.Item[i] := 0
			}
			else
			{
				lst.Item[i] := sum
				iCarry := 0
				break
			}
			i--
		}
		if (iCarry = 1)
		{
			lst.Insert(0, 1)
		}
	}
; 	End:_AddOneToNibListValue ;}
;{ _CompareUnSignedIntegerArraysBe
	_CompareUnSignedIntegerArraysBe(objA, objB) {
		
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		x := 0
		y := 0
		
		While ((x < objA.Count) && (objA.Item[x] = 0))
		{
			x++
		}
		While ((y < objB.Count) && (objB.Item[y] = 0))
		{
			y++
		}
		if (x = 0 && y = 0)
		{
			NumA := objA.Item[x]
			MumB := objB.Item[y]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			return 0
		}
		
		xOffset := objA.Count - x
		yOffset := objA.Count - y
		if (xOffset > yOffset)
		{
			return 1
		}
		if (xOffset < yOffset)
		{
			return -1
		}
		; array non zero index are the same length
		xOffset := x
		yOffset := y
		while yOffset < objB.Count
		{
			NumA := objA.Item[xOffset]
			MumB := objB.Item[yOffset]
			if (NumA > MumB)
			{
				return 1
			}
			if (NumA < MumB)
			{
				return -1
			}
			xOffset++
			yOffset++
		}
		return 0
	}
; End:_CompareUnSignedIntegerArraysBe ;}
;{ 	_FlipNibbles
	_FlipNibbles(lst) {
		nArray := new MfNibbleList()
		iMaxIndex := lst.Count - 1
		for i, b in lst
		{
			Hex := MfNibConverter._GetHexValue(b)
			bInfo := MfNibConverter.HexBitTable[Hex]
			bInfoFlipped := MfNibConverter.HexBitTable[bInfo.HexFlip]
			
			nArray.Add(bInfoFlipped.IntValue)
		}
		return nArray
	}
; 	End:_FlipNibbles ;}
;{ 	_HexToDecimal
	_HexToDecimal(nibbles, startIndex=-1) {
		_startIndex := MfInteger.GetValue(startIndex, -1)
		if (_startIndex < 0)
		{
			_startIndex := 0
		}
		x := _startIndex
		while ((x < nibbles.Count) && (nibbles.Item[x] = 0))
		{
			x++
		}
		dec := new MfList() ; decimal result
		dec.Add(0)
		i := x
		while i < nibbles.Count
		{
			n := nibbles.Item[i]
			carry := n
			; initially holds decimal value of current hex digit;
			; subsequently holds carry-over for multiplication
			
			for j, int in dec
			{
				val := (int * 16) + carry
				valMod := Mod(val, 10)
				dec.Item[j] := valMod
				carry := val // 10
			}
			while (carry > 0)
			{
				dec.Add(Mod(carry, 10))
				carry := carry // 10
			}
			i++
		}
		i := dec.Count - 1
		retval := ""
		while i >= 0
		{
			retval .= dec.Item[i]
			i--
		}
		return retval
	}
; 	End:_HexToDecimal ;}
;{ 	_NibListsAdd
	_NibListsAdd(lstA, lstB) {
		; lstA.Count is assumed to be greater then or equal to lstB.count
		aLong := Compare > 0
		
		ans := new MfNibbleList()
		iCarry := 0
		i := lstB.Count - 1
		offset := lstA.Count - lstB.Count
		iCount := 0
		while i >= 0
		{
			j := i + offset
			nA := lstA.Item[j]
			nB := lstB.Item[i]
			sum := (nA + nB) + iCarry
			R := 0
			if (sum > 0)
			{
				q := MfMath.DivRem(sum, 16, R)
				iCarry := q
			}
			ans.Add(R)
			i--
			iCount++
		}
		i :=  lstA.Count - 1 - iCount
		While (iCarry > 0)
		{
			R := 0
			if (i >= 0)
			{
				nA := lstA.Item[i]
				sum := nA  + iCarry
				iCarry := 0
				if (sum > 0)
				{
					iCarry := MfMath.DivRem(sum, 16, R)
				}
				i--
				iCount++
			}
			else
			{
				iCarry := MfMath.DivRem(iCarry, 16, R)
			}
			
			ans.Add(R)
		}
		; if there are any remainint elements in lstA add them to ans
		i := lstA.Count - 1 - iCount
		while i >= 0
		{
			ans.Add(lstA.Item[i])
			i--
			iCount++
		}
		
		; create a new list to hold the reverse nibbles
		result := new MfNibbleList()
		i := 0
				
		i := ans.count -1
		while i >= 0
		{
			result.Add(ans.Item[i])
			i--
		}
		return result
		
	}
; 	End:_NibListsAdd ;}
;{ 	_NibListMultiplyByNib
	_NibListMultiplyByNib(lst, iNib, ShiftAmount=0) {
		ans := new MfNibbleList()
		iCarry := 0
		i := lst.Count - 1
		bZero := true
		while i >= 0
		{
			n := lst.Item[i]
			p := (n * iNib) + iCarry
			R := 0
			iCarry := 0
			if (p > 0)
			{
				bZero := false
				iCarry := MfMath.DivRem(p, 16, R)
			}
			ans.Add(R)
			i--
		}
		if (bZero)
		{
			ans.Clear()
			ans.Add(0)
			return ans
		}
		While (iCarry > 0)
		{
			iCarry := MfMath.DivRem(iCarry, 16, R)
			ans.Add(R)
		}
		x := ans.count -1
		while ans.Item[x] = 0 && x >= 0
		{
			x--
		}
		result := new MfNibbleList()
		i := x
		while i >= 0
		{
			result.Add(ans.Item[i])
			i--
		}
		
		i := 0
		while i < ShiftAmount
		{
			result.Add(0)
			i++
		}
		
		return result
	}
; 	End:_NibListMultiplyByNib ;}
;{ 	_MultiplyNibList
	_MultiplyNibList(lstA, lstB){
		; Order of array is expected to be left to right making lst.Count -1 the MSB
		; in this method LstA.count is excpected to be Greater then or equal to  lstB.Count
		; lstB.Count tells us how many arrays will need to be added together in the end
		; lstA to be Multiplied by lstB
		lst := new MfList()
		
		
		iMaxIndexA := lstA.Count - 1
		iMaxIndexB := lstB.Count - 1
		
		x := 0
		While lstB.Item[x] = 0 && x < lstB.Count
		{
			x++
		}

		if (x >= lstB.Count)
		{
			return lstA
		}
		iStartIndexA := x
		i := iMaxIndexB
		iCount := 0
		jCount := 0
		While i >= iStartIndexA
		{
			n := lstB.Item[i]
			iResult := MfNibConverter._NibListMultiplyByNib(lstA, n, iCount)
			lst.Add(iResult)
			iCount ++
			i--
		}
		lstN := lst.Item[0]
		
		if (lst.Count <= 1)
		{
			return lstN
		}
		ans := new MfNibbleList()
		i := 0
		for i, n in lstN
		{
			ans.Add(n)
		}
		i := 0
		for i, obj in lst
		{
			if (i = 0)
			{
				continue
			}
			lstN := lst.Item[i]
			ans := MfNibConverter.NibbleListAdd(ans, lstN)
			
		}
		return ans
	}
; 	End:_MultiplyNibList ;}
;{ _GetHexValue
	_GetHexValue(i)	{
		iChar := 0
		if (i < 10)
		{
			iChar := i + 48
		}
		else
		{
			iChar := (i - 10) + 65
		}
		return Chr(iChar)
	}
; End:_GetHexValue ;}
;{ 	_GetBytesInt
	_GetBytesInt(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (bitCount > 64)
		{
			; will handle negative and positive and convert to Little Endian
			return MfNibConverter._LongIntStringToHexArray(value, bitCount)
		}
		return MfNibConverter._IntToHexArray(value, bitCount)

	}
; 	End:_GetBytesInt ;}
	_LongIntStringToHexArray(strN, bitCount = 32) {
		throw new MfNotImplementedException("_LongIntStringToHexArray not implemented")
	}
;{ 	_IntToHexArray
	_IntToHexArray(value, bitCount = 32) {
		If (bitCount < 4 )
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Under", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (Mod(bitCount, 4))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		r := ""
		retval := ""
		
		IsNegative := false
		nArray := new MfNibbleList()
		ActualBitCount := bitCount // 2
		MaxMinValuCorrect := false
		if (value = 0)
		{
			while (nArray.Count * 2) < ActualBitCount
			{
				nArray.Add(0)
			}
			return nArray
		}
		if (value < 0)
		{
			IsNegative := true
			; The Absolute value of MfInt64.MinValue is 1 greater then then MfInt64.MaxValue
			; therefore Abs(MfInt64.MinValue) will return the same negative value
			; to get around this add 1 if value = MfInt64.MinValue and subtact if from the bit array
			; this is a one off case and only happens when value is max int min value.
			if (value = MfInt64.MinValue)
			{
				Result := Abs((value + 1))
				MaxMinValuCorrect := true
			}
			else
			{
				Result := Abs(value)
			}
		}
		else
		{
			Result := value
		}
		while Result > 0
		{
			
			
			i := 0
			MSB := ""
			LSB := ""
			while i < 2
			{
				byte := ""
				if (Result = 0)
				{
					break
				}
				r := Mod(Result, 16)
				Result := Result // 16
				
				if (r <= 9)
				{
					byte := r
				}
				else if (r = 10)
				{
					byte := "A"
				}
				else if (r = 11)
				{
					byte := "B"
				}
				else if (r = 12)
				{
					byte := "C"
				}
				else if (r = 13)
				{
					byte := "D"
				}
				else if (r = 14)
				{
					byte := "E"
				}
				else
				{
					byte := "F"
				}
				if (i = 0)
				{
					LSB := byte
				}
				else
				{
					MSB := byte
					MsbInfo := MfNibConverter.HexBitTable[MSB]
					LsbInfo := MfNibConverter.HexBitTable[LSB]
					nArray.Add(LsbInfo.IntValue)
					nArray.Add(MsbInfo.IntValue)
				}
				if ((Result = 0) && (i = 0))
				{
					LsbInfo := MfNibConverter.HexBitTable[LSB]
					nArray.Add(LsbInfo.IntValue)
					nArray.Add(0)
				}
				i++
			}
		}
		
				
		if (IsNegative)
		{
			while (nArray.Count * 2) < ActualBitCount
			{
				nArray.Add(0)
			}
			nArray := MfNibConverter._ReverseList(nArray)
			; flip all the bits
			nArray := MfNibConverter._FlipNibbles(nArray)

			if (MaxMinValuCorrect = False)
			{
				;~ ; when negative Add 1
				IsAdded := MfNibConverter._AddOneToNibList(nArray, false)
			}
		}
		else ; if (IsNegative)
		{
			; add zero's to end of postivie array
			while (nArray.Count * 2) < ActualBitCount
			{
				nArray.Add(0)
			}
			nArray := MfNibConverter._ReverseList(nArray)
		}
		return nArray
	}
; 	End:_IntToHexArray ;}
;{ _ReverseList
	_ReverseList(lst) {
		iCount := lst.Count
		nArray := new MfNibbleList()
		while iCount > 0
		{
			index := iCount -1
			nArray.Add(lst.Item[index])
			iCount --
		}
		return nArray
	}
; End:_ReverseList ;}
; End:Internal Methods ;}
;{ Properties
	;{ IsLittleEndian
		/*!
			Property: IsLittleEndian [get]
				Indicates the byte order ("endianness") in which data is stored in this computer architecture
			Value:
				Var representing the IsLittleEndian property of the instance
			Remarks:
				Readonly Property
				Returns false
		*/
		IsLittleEndian[]
		{
			get {
				return false
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "IsLittleEndian")
				Throw ex
			}
		}
	; End:IsLittleEndian ;}
; End:Properties ;}
	;{ HexBitTable
		static m_HexBitTable := ""
		/*!
			Property: HexBitTable [get]
				Gets the HexBitTable value associated with the this instance
			Value:
				Var representing the HexBitTable property of the instance
			Remarks:
				Readonly Property
		*/
		HexBitTable[key]
		{
			get {
				if (MfNibConverter.m_HexBitTable = "")
				{
					MfNibConverter.m_HexBitTable := new MfHashTable(16)
					MfNibConverter.m_HexBitTable.Add("0", new MfNibConverter.HexBitInfo("0", "F", "0000","1111", 0))
					MfNibConverter.m_HexBitTable.Add("1", new MfNibConverter.HexBitInfo("1", "E", "0001","1000", 1))
					MfNibConverter.m_HexBitTable.Add("2", new MfNibConverter.HexBitInfo("2", "D", "0010","1101", 2))
					MfNibConverter.m_HexBitTable.Add("3", new MfNibConverter.HexBitInfo("3", "C", "0011","1100", 3))
					MfNibConverter.m_HexBitTable.Add("4", new MfNibConverter.HexBitInfo("4", "B", "0100","1011", 4))
					MfNibConverter.m_HexBitTable.Add("5", new MfNibConverter.HexBitInfo("5", "A", "0101","1010", 5))
					MfNibConverter.m_HexBitTable.Add("6", new MfNibConverter.HexBitInfo("6", "9", "0110","1001", 6))
					MfNibConverter.m_HexBitTable.Add("7", new MfNibConverter.HexBitInfo("7", "8", "0111","1000", 7))

					MfNibConverter.m_HexBitTable.Add("8", new MfNibConverter.HexBitInfo("8", "7", "1000","0111", 8, true))
					MfNibConverter.m_HexBitTable.Add("9", new MfNibConverter.HexBitInfo("9", "6", "1001","0110", 9, true))
					MfNibConverter.m_HexBitTable.Add("A", new MfNibConverter.HexBitInfo("A", "5", "1010","0101", 10, true))
					MfNibConverter.m_HexBitTable.Add("B", new MfNibConverter.HexBitInfo("B", "4", "1011","0100", 11, true))
					MfNibConverter.m_HexBitTable.Add("C", new MfNibConverter.HexBitInfo("C", "3", "1100","0011", 12, true))
					MfNibConverter.m_HexBitTable.Add("D", new MfNibConverter.HexBitInfo("D", "2", "1101","0010", 13, true))
					MfNibConverter.m_HexBitTable.Add("E", new MfNibConverter.HexBitInfo("E", "1", "1000","0001", 14, true))
					MfNibConverter.m_HexBitTable.Add("F", new MfNibConverter.HexBitInfo("F", "0", "1111","0000", 15, true))
				}
				return MfNibConverter.m_HexBitTable.Item[key]
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "HexBitTable")
				Throw ex
			}
		}
	; End:HexBitTable ;}
; End:Properties ;}
;{ Internal Class HexBitInfo
	class HexBitInfo
	{
		__new(hv, hf, b, bf, int, Neg = false) {
			this.HexValue := hv
			this.HexFlip := hf
			this.Bin := b
			this.BinFlip := bf
			this.IntValue := int
			this.IsNeg := Neg
		}
		HexValue := ""
		HexFlip := ""
		Bin := ""
		BinFlip := ""
		IsNeg := False
		IntValue := 0
	}
; End:Internal Class HexBitInfo ;}
}