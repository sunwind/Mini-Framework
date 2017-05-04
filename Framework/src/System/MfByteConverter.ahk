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

class MfByteConverter extends MfObject
{
	static bpe := 8
	static mask := 255
	static radix := 256
;{ Methods

;{ 	CompareUnsignedByteList
	CompareUnsignedByteList(objA, objB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		return MfByteConverter._CompareUnSignedIntegerArraysLe(objA, objB)
	}
; 	End:CompareUnsignedByteList ;}
;{ 	CompareSignedByteList
	CompareSignedByteList(objA, objB)	{
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(objA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "objA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(objB, MfByteList) = false)
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
		MostSigbitA := MfByteConverter._GetFirstHexNumber(objA.Item[objA.Count -1])
		MostSigbitInfoA := MfNibConverter.HexBitTable[MostSigbitA]
		
		MostSigbitB := MfByteConverter._GetFirstHexNumber(objB.Item[objB.Count -1])
		MostSigbitInfoB := MfNibConverter.HexBitTable[MostSigbitB]
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
			return MfByteConverter._CompareUnSignedIntegerArraysLe(objA, objB)
		}
		if (MostSigbitInfoA.IsNeg = true)
		{
			ObjA := MfByteConverter._FlipBytes(ObjA)
		}
		if (MostSigbitInfoB.IsNeg = true)
		{
			ObjB := MfByteConverter._FlipBytes(ObjB)
		}
		result := MfByteConverter._CompareUnSignedIntegerArraysLe(objA, objB)
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
; 	End:CompareSignedByteList ;}
	Expand(bytes, n, UseMsb=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		n := MfInteger.GetValue(n, 0)
		UseMsb := MfBool.GetValue(UseMsb, true)
		
		If (bytes.Count >= n)
		{
			return bytes.Clone()
		}

		MSB := 0
		if (UseMsb = true && bytes.Count > 0)
		{
			b := bytes.Item[bytes.Count - 1]
			bHigh := MfByteConverter.GetNibbleHigh(b)

			Hex := MfByteConverter._GetFirstHexNumber(b)
			bInfo := MfNibConverter.HexBitTable[Hex]
			if (bInfo.IsNeg)
			{
				MSB := 255
			}
		}
		iCount := bytes.Count
		diff := n - iCount
		retval := new MfByteList()

		bl := retval.m_InnerList
		ll := bytes.m_InnerList

		; ByteFirst := -1
		; If ((iCount > 0))
		; {
		; 	ByteFirst := ll[ll.Count]
		; }

		
		i := 1
		while (i <= bytes.Count)
		{
			bl[i] := ll[i]
			i++
		}
		j := i
		i := 1
		While (i <= diff)
		{
			bl[j] := MSB
			i++
			j++
		}
		retval.m_Count := bl.Length()
		return retval
	}
;{ GetBytes
	GetBytes(obj) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if (!IsObject(obj))
		{
			Nibbles := MfNibConverter.GetNibbles(obj)
			return MfNibConverter.ToByteList(Nibbles)
		}
		
		wf := A_FormatInteger
		Try
		{
			SetFormat, IntegerFast, d
			if (MfObject.IsObjInstance(obj, MfBool))
			{
				if (obj.Value = true)
				{
					return MfByteConverter._GetBytesInt(1, 8, true)
				}
				return MfByteConverter._GetBytesInt(0, 8, true)
			}
			else if (MfObject.IsObjInstance(obj, MfChar))
			{
				return MfByteConverter._GetBytesInt(obj.CharCode, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInt16))
			{
				return MfByteConverter._GetBytesInt(obj.Value, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt16))
			{
				return MfByteConverter._GetBytesInt(obj.Value, 16)
			}
			else if (MfObject.IsObjInstance(obj, MfInteger))
			{
				return MfByteConverter._GetBytesInt(obj.Value, 32)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt32))
			{
				return MfByteConverter._GetBytesInt(obj.Value, 32)
			}
			else if (MfObject.IsObjInstance(obj, MfInt64))
			{
				return MfByteConverter._GetBytesInt(obj.Value, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfUInt64))
			{
				nibs := MfNibConverter.GetNibbles(obj)
				return MfNibConverter.ToByteList(nibs)
			}
			else if (MfObject.IsObjInstance(obj, MfFloat))
			{
				int := MfByteConverter._FloatToInt64(obj.Value)
				return MfByteConverter._GetBytesInt(int, 64)
			}
			else if (MfObject.IsObjInstance(obj, MfBigInt))
			{
				
				nibs := MfNibConverter.GetNibbles(obj)
				return MfNibConverter.ToByteList(nibs)
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
; End:GetBytes ;}
;{ GetNibbleHigh
	GetNibbleHigh(byte) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_byte := MfByte.GetValue(byte)
		return MfByteConverter._GetFirstHexNumber(_byte)
	}
; End:GetNibbleHigh ;}
;{ GetNibbleLow
	GetNibbleLow(Byte) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		_byte := MfByte.GetValue(byte)
		return MfByteConverter._GetSecondHexNumber(_byte)
	}
; End:GetNibbleLow ;}
;{ 	BytesAdd
	BytesAdd(BytesA, BytesB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(BytesA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(BytesB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nibA := MfNibConverter.FromByteList(BytesA)
		nibB := MfNibConverter.FromByteList(BytesB)
		nibResult := MfNibConverter.NibbleListAdd(nibA, nibB)
		result := MfNibConverter.ToByteList(nibResult)
		return result
	}
; 	End:BytesAdd ;}
;{ 	BytesMultiply
	BytesMultiply(BytesA, BytesB) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(BytesA, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(MfObject.IsObjInstance(BytesB, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesA.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesA"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(BytesB.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "BytesB"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nibA := MfNibConverter.FromByteList(BytesA)
		nibB := MfNibConverter.FromByteList(BytesB)
		nibResult := MfNibConverter.NibbleListMultiply(nibA, nibB)
		result := MfNibConverter.ToByteList(nibResult)
		return result
	}
; 	End:BytesMultiply ;}
;{ ToBool
	ToBool(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (bytes.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := bytes.Item[_startIndex] != 0
		if (_ReturnAsObj)
			return new MfBool(retval)
		return retval
	}

; End:ToBool ;}
;{ 	ToByte
	ToByte(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(nibbles.Count < 1)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if ((_startIndex < 0) || (_startIndex > (bytes.Count - 1)))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		retval := "0x"
		b := bytes.Item[_startIndex]
		HexChar1 := MfByteConverter._GetFirstHexNumber(b)
		HexChar2 := MfByteConverter._GetSecondHexNumber(b)
		retval .= HexChar1 . HexChar2
		retval := retval + 0x0

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
	ToChar(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		result := MfByteConverter.ToInt16(bytes, startIndex, false)
		if (result < 0)
		{
			result := Abs(result)
		}
		c := new MfChar()
		c.CharCode := result
		if (_ReturnAsObj)
		{
			return c
		}
		return c.Value
	}
; End:ToChar ;}
;{ ToInt16
	ToInt16(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 1))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		bArray := new MfByteList()
		bya := bytes.m_InnerList
		i := 0
		while i < 2
		{
			index := i + _startIndex + 1
			itm := bya[index]
			bArray._Add(itm)
			i++
		}
		if (MfByteConverter.IsLittleEndian)
		{
			bArray := MfByteConverter._SwapBytes(bArray)
		}
		sb := new MfText.StringBuilder()
		
		HexKey := MfByteConverter._GetFirstHexNumber(bArray.Item[0])
		bInfo := MfNibConverter.HexBitTable[HexKey]
		IsNeg := bInfo.IsNeg
		if (IsNeg)
		{
			ba := bArray.m_InnerList
			sb.Append("-")
			for i, b in ba
			{
				Hex1 := MfByteConverter._GetFirstHexNumber(b)
				Hex2 := MfByteConverter._GetSecondHexNumber(b)
				bInfo1 := MfNibConverter.HexBitTable[Hex1]
				bInfo2 := MfNibConverter.HexBitTable[Hex2]
				FlipHex := "0x" . bInfo1.HexFlip . bInfo2.HexFlip
				FlipHex := FlipHex + 0x0
				ba[i] := FlipHex
			}
		}
		sb.Append("0x")
		for i , b in bArray
		{

			HexChar1 := MfByteConverter._GetFirstHexNumber(b)
			HexChar2 := MfByteConverter._GetSecondHexNumber(b)
			sb.Append(HexChar1)
			sb.Append(HexChar2)
		}
		retval := sb.ToString() + 0x0
		sb := ""
		if (IsNeg)
		{
			retval := retval - 0x1
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

;{ ToInt32
	ToInt32(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 3))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		bInLst := bytes.m_InnerList
		i := 0
		while i < 4
		{
			index := i + _startIndex + 1
			itm := bInLst[index]
			bArray._Add(itm)
			i++
		}
		if (MfByteConverter.IsLittleEndian)
		{
			bArray := MfByteConverter._SwapBytes(bArray)
		}
		sb := new MfText.StringBuilder()
		HexKey := MfByteConverter._GetFirstHexNumber(bArray.Item[0])
		bInfo := MfNibConverter.HexBitTable[HexKey]
		IsNeg := bInfo.IsNeg
		if (IsNeg)
		{
			ba := bArray.m_InnerList
			sb.Append("-")
			for i, b in ba
			{
				Hex1 := MfByteConverter._GetFirstHexNumber(b)
				Hex2 := MfByteConverter._GetSecondHexNumber(b)
				bInfo1 := MfNibConverter.HexBitTable[Hex1]
				bInfo2 := MfNibConverter.HexBitTable[Hex2]
				FlipHex := "0x" . bInfo1.HexFlip . bInfo2.HexFlip
				FlipHex := FlipHex + 0x0
				ba[i] := FlipHex
			}
		}
		sb.Append("0x")
		for i , b in bArray
		{

			HexChar1 := MfByteConverter._GetFirstHexNumber(b)
			HexChar2 := MfByteConverter._GetSecondHexNumber(b)
			sb.Append(HexChar1)
			sb.Append(HexChar2)
		}
		retval := sb.ToString() + 0x0
		sb := ""
		if (IsNeg)
		{
			retval := retval - 0x1
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
; End:ToInt32 ;}
;{ ToInt64
	ToInt64(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 7))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		bInLst := bytes.m_InnerList
		i := 0
		while i < 8
		{
			index := i + _startIndex + 1
			itm := bInLst[index]
			bArray._Add(itm)
			i++
		}
		if (MfByteConverter.IsLittleEndian)
		{
			bArray := MfByteConverter._SwapBytes(bArray)
		}
		sb := new MfText.StringBuilder(20)
		HexKey := MfByteConverter._GetFirstHexNumber(bArray.Item[0])
		bInfo := MfNibConverter.HexBitTable[HexKey]
		IsNeg := bInfo.IsNeg
		if (IsNeg)
		{
			sb.Append("-")
			ba := bArray.m_InnerList
			for i, b in ba
			{
				Hex1 := MfByteConverter._GetFirstHexNumber(b)
				Hex2 := MfByteConverter._GetSecondHexNumber(b)
				bInfo1 := MfNibConverter.HexBitTable[Hex1]
				bInfo2 := MfNibConverter.HexBitTable[Hex2]
				FlipHex := "0x" . bInfo1.HexFlip . bInfo2.HexFlip
				FlipHex := FlipHex + 0x0
				ba[i] := FlipHex
			}
		}
		sb.Append("0x")
		for i , b in bArray
		{

			HexChar1 := MfByteConverter._GetFirstHexNumber(b)
			HexChar2 := MfByteConverter._GetSecondHexNumber(b)
			sb.Append(HexChar1)
			sb.Append(HexChar2)
		}
		retval := sb.ToString() + 0x0
		sb := ""
		if (IsNeg)
		{
			retval := retval - 0x1
		}
		if (_ReturnAsObj)
		{
			return new MfInt64(retval)
		}
		return retval
	}
; End:ToInt64 ;}
;{ 	ToUInt16
	ToUInt16(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 1))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		bArray := new MfByteList()
		i := 0
		while i < 2
		{
			index := i + _startIndex
			itm := bytes.Item[index]
			bArray.Add(itm)
			i++
		}
		if (MfByteConverter.IsLittleEndian)
		{
			bArray := MfByteConverter._SwapBytes(bArray)
		}

		sb := new MfText.StringBuilder()
		sb.Append("0x")
		
		for i , b in bArray
		{

			HexChar1 := MfByteConverter._GetFirstHexNumber(b)
			HexChar2 := MfByteConverter._GetSecondHexNumber(b)
			sb.Append(HexChar1)
			sb.Append(HexChar2)
		}
		retval := sb.ToString() + 0x0
		
		if ((retval < MfUInt16.MinValue) || (retval > MfUInt16.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt16"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfUInt16(retval)
		}
		return retval
	}
; 	End:ToUInt16 ;}
;{ 	ToUInt32
	ToUInt32(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 3))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		ba := bytes.m_InnerList
		i := 0
		while i < 4
		{
			index := i + _startIndex + 1
			itm := ba[index]
			bArray._Add(itm)
			i++
		}
		if (MfByteConverter.IsLittleEndian)
		{
			bArray := MfByteConverter._SwapBytes(bArray)
		}
		sb := new MfText.StringBuilder(16)
		sb.Append("0x")
		

		for i , b in bArray
		{

			HexChar1 := MfByteConverter._GetFirstHexNumber(b)
			HexChar2 := MfByteConverter._GetSecondHexNumber(b)
			sb.Append(HexChar1)
			sb.Append(HexChar2)

		}
		retval := sb.ToString() + 0x0
		sb := ""
		
		if ((retval < MfUInt32.MinValue) || (retval > MfUInt32.MaxValue)) {
			ex := new MfOverflowException(MfEnvironment.Instance.GetResourceString("Overflow_UInt32"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_ReturnAsObj)
		{
			return new MfUInt32(retval)
		}
		return retval
	}
; 	End:ToUInt32 ;}
;{ ToUInt64
	ToUInt64(bytes, startIndex = 0, ReturnAsObj = false) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInt64.GetValue(startIndex, 0)
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		iMaxIndex := bytes.Count - 1
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (_startIndex >= (bytes.Count - 7))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		bArray := new MfByteList()
		ba := bytes.m_InnerList
		i := 0
		while i < 8
		{
			index := i + _startIndex + 1
			itm := ba[index]
			bArray._Add(itm)
			i++
		}
		if (MfByteConverter.IsLittleEndian)
		{
			;bArray := MfByteConverter._SwapBytes(bArray)
		}
		retval := MfByteConverter._LongHexArrayToLongInt(bArray)
		
		if (_ReturnAsObj)
		{
			return new MfUInt64(retval)
		}
		return retval
	}
; End:ToUInt64 ;}
;{ 	ToBigInt
	ToBigInt(bytes, startIndex=0 , Length=-1, ReturnAsObj=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		Length := MfInteger.GetValue(Length, 1)
		if (Length < 0)
		{
			Length := bytes.Count
		}
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		
		if (_startIndex < ((bytes.Count - _startIndex ) - Length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayTooSmall", "nibbles"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > 0 && Length != bytes.Count)
		{
			bytes := bytes.SubList(startIndex, Length - 1)
		}
		; get Nibbles from Bytes
		nibs := MfNibConverter.FromByteList(bytes)
		return MfNibConverter.ToBigInt(nibs)


	}
; 	End:ToBigInt ;}
;{ ToFloat
	ToFloat(bytes, startIndex = 0, ReturnAsObj = false) {
		_ReturnAsObj := MfBool.GetValue(ReturnAsObj, false)
		int := MfByteConverter.ToInt64(bytes, startIndex, false)
		retval := MfByteConverter._Int64ToFloat(int)
		retval += 0.0
		if (_ReturnAsObj)
		{
			return new MfFloat(retval)
		}
		return retval
	}
; End:ToFloat ;}

;{ 	ToIntegerString
	ToIntegerString(bytes, startIndex=0) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_startIndex := MfInteger.GetValue(startIndex, 0)
		if ((_startIndex < 0) || (_startIndex >= bytes.Count))
		{
			ex := new MfArgumentOutOfRangeException("startIndex")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		nibList := MfNibConverter.FromByteList(bytes, _startIndex)
		return MfNibConverter.ToIntegerString(nibList)
	}
; 	End:ToIntegerString ;}
;{ ToString
	ToString(bytes, returnAsObj = false, startIndex = 0, length="") {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		_returnAsObj := MfBool.GetValue(returnAsObj, false)
		_startIndex := MfInt64.GetValue(startIndex, 0)
		if (_startIndex < 0)
		{
			ex := new MfArgumentOutOfRangeException("startIndex", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_StartIndex"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if (MfNull.IsNull(length)) {
			_length := bytes.Count - _startIndex
		}
		else
		{
			_length := MfInt64.GetValue(length)
		}
		if (_length < 0)
		{
			ex := new MfArgumentOutOfRangeException("length", MfEnvironment.Instance.GetResourceString("ArgumentOutOfRange_GenericPositive"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		if (_startIndex > (bytes.Count - _length))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayPlusOffTooSmall"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		sb := new MfText.StringBuilder((_length * 2) + 1)
		i := _startIndex + 1
		iCount := 0
		bInLst := bytes.m_InnerList
		while i <= _length
		{
			b := bInLst[i]
			bit1 := b // 16
			bit2 := Mod(b, 16)
			bitChar1 := MfByteConverter._GetHexValue(bit1)
			bitChar2 := MfByteConverter._GetHexValue(bit2)

			if (iCount > 0)
			{
				sb.Append("-")
				sb.Append(bitChar1)
				sb.Append(bitChar2)
			}
			Else
			{
				sb.Append(bitChar1)
				sb.Append(bitChar2)
			}
			i++
			iCount++
		}
		return _returnAsObj = true?new MfString(sb.ToString()):sb.ToString()
	}
; End:ToString ;}
	Trim(bytes, n=0, UseMsb=true) {
		this.VerifyIsNotInstance(A_ThisFunc, A_LineFile, A_LineNumber, A_ThisFunc)
		if(MfObject.IsObjInstance(bytes, MfByteList) = false)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Incorrect_List", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		if(bytes.Count = 0)
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Arg_ArrayZeroError", "bytes"))
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}
		n := MfInteger.GetValue(n, 0)
		UseMsb := MfBool.GetValue(UseMsb, true)
		if (n < 0)
		{
			n = -n
		}
		MSB := 0
		if (UseMsb)
		{
			MostSigbit := MfByteConverter._GetFirstHexNumber(bytes.Item[bytes.Count -1])
			Info := MfNibConverter.HexBitTable[MostSigbit]
			if (Info.IsNeg)
			{
				MSB := 255
			}
		}
		i := bytes.Count
		while (i >= 1 && bytes.m_InnerList[i] = MSB)
		{
			i--
		}
		y := new MfByteList(i + n, MSB)
		if (i = 0)
		{
			; if j = the we have all leading bits of 0 or all leading bits or 1
			; make sure to return at least n + 1 bits for a min of one bit
			y.Add(MSB)
			return y
		}
		MfByteConverter._copy(y, bytes, MSB)
		return y
	}
;{ 	Methods
;{ Internal Methods
	;{ 	_copy
	; do x=y on x and y.  x must be an list
	; at least as big as y (not counting the leading zeros in y).
	_copy(ByRef x, y, MSB=0) {
		k := x.m_Count < y.m_Count ? x.m_Count : y.m_Count
		xl := x.m_InnerList
		yl := y.m_InnerList
		i := 1
		while (i <= k)
		{
			xl[i] := yl[i]
			i++
		}
		i := k
		while (i < x.m_Count)
		{
			xl[i] := MSB
			i++
		}
	}
; 	End:_copy ;}
	divInt_(byRef x, n) {
		r := 0
		i := 1
		ll := x.m_InnerList
		while (i < x.Count)
		{
			s := r * MfByteConverter.radix + ll[i]
			ll[i] := s // n
			r := Mod(s , n)
			i++
		}
		return r
	}
	multInt_(ByRef x, n) {
		xl := x.m_InnerList
		if (!n)
		{
			return
		}
		k := 1
		c := 0
		i := x.Count
		while (i >= k)
		{
			c += xl[i] * n
			b := 0
			if (c < 0)
			{
				b := -(c >> MfByteConverter.bpe)
				c += b * MfByteConverter.radix
			}
			xl[i] := c & MfByteConverter.mask
			c := (c >> MfByteConverter.bpe) - b
			i--
		}
		x.m_Count := xl.Length()
	}
;{ 	_CompareUnSignedIntegerArraysLe
	_CompareUnSignedIntegerArraysLe(objA, objB) {
		
		if(objA.Count = 0)
		{
			return -1
		}
		if(objB.Count = 0)
		{
			return 1
		}
		x := objA.Count - 1
		y := objB.Count - 1
		
		While objA.Item[x] = 0 && x > -1
		{
			x--
		}
		While objB.Item[y] = 0 && y > -1
		{
			y--
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
		
		if (x > y)
		{
			return 1
		}
		if (x < y)
		{
			return -1
		}
		; array non zero index are the same length
		xOffset := x
		yOffset := y
		while yOffset >= 0
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
			xOffset--
			yOffset--
		}
		return 0
	}
; 	End:_CompareUnSignedIntegerArraysLe ;}

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
;{ _GetFirstHexNumber
	_GetFirstHexNumber(byte) {
		Hex1 := byte // 16
		Hex := MfByteConverter._GetHexValue(Hex1)
		return Hex
	}
; End:_GetFirstHexNumber ;}
;{ _GetSecondHexNumber
	_GetSecondHexNumber(byte) {
		Hex1 := Mod(byte, 16)
		Hex := MfByteConverter._GetHexValue(Hex1)
		return Hex
	}
; End:_GetSecondHexNumber ;}
;{ 	_IsNotMfObj
	_IsNotMfObj(obj) {
		if (MfObject.IsObjInstance(obj))
		{
			return false
		}
		
		ex := new MfException(MfEnvironment.Instance.GetResourceString("NonMfObjectException_General"))
		ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
		return ex
	}
; 	End:_IsNotMfObj ;}
;{ 	_GetBytesInt
	_GetBytesInt(value, bitCount = 64) {
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
			return MfByteConverter._LongIntStringToHexArray(value, bitCount)
		}
		return MfByteConverter._IntToHexArray(value, bitCount)

	}
; 	End:_GetBytesInt ;}
;{ 	_GetBytesUInt
	_GetBytesUInt(value, bitCount = 32) {
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
		if (bitCount >= 64)
		{
			; remove any sign
			_val := value . ""
			if (_val ~= "^-[0-9]+$")
			{
				_val := SubStr(_val, 2, (StrLen(_val) -1))
			}
			else if (_val ~= "^\+[0-9]+$")
			{
				_val := SubStr(_val, 2, (StrLen(_val) -1))
			}
			if (!(_val ~= "^[0-9]+$"))
			{
				ex := new MfInvalidCastException(MfEnvironment.Instance.GetResourceString("InvalidCastException_ValueToInteger"))
				ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
				throw ex
			}
			; will handle negative and positive and convert to Little Endian
			return MfByteConverter._LongIntStringToHexArray(value, bitCount)
		}
		return MfByteConverter._IntToHexArray(Abs(value), bitCount)

	}
; 	End:_GetBytesUInt ;}
;{ _LongHexStringToLongInt
	; takse a MfByteList of hex values and converts to a postive string value of integer
	; in theroy no limit to the number of bytes that can be turned
	; into string integer
	_LongHexArrayToLongInt(lst) {
		; bInfo := MfNibConverter.HexBitTable[lst.Item[0]]
		; IsNeg := bInfo.IsNeg
		bArray := new MfList()
		; remove leading zero's this should speed up long string
		; multiplers later on
		IsleadZero := true
		for i , b in lst
		{
			if ((IsleadZero = true) && (b = 0))
			{
				Continue
			}

			Hex1 := MfByteConverter._GetFirstHexNumber(b)
			Hex2 := MfByteConverter._GetSecondHexNumber(b)
			bInfo1 := MfNibConverter.HexBitTable[Hex1]
			bInfo2 := MfNibConverter.HexBitTable[Hex2]
			IsleadZero = False
			bArray.Add(bInfo1.HexValue)
			bArray.Add(bInfo2.HexValue)
		}

		sResult := "0"
		sCount := "1"
		iLoop := bArray.Count - 1
		iCount := 0
		sPower := "1"
		while iLoop >= 0
		{

			if (iCount > 0)
			{

				; we do not have a power of operater for long string so on each loop Multiply
				; to mimic the power of for hex
				sPower := MfUInt64._LongIntStringMult(sPower, 16)
			}
			b := bArray.Item[iLoop]
			bi := MfNibConverter.HexBitTable[b]
			if (bi.IntValue > 0)
			{
				s := MfUInt64._LongIntStringMult(sPower, bi.IntValue)
				sResult := MfUInt64._LongIntStringAdd(sResult, s)
			}
			iCount++
			iLoop--
		}
		return sResult
	}
; End:_LongHexStringToLongInt ;}
	; takse a MfByteList of hex values and converts to a Negative string value of integer
	; in theroy no limit to the number of bytes that can be turned
	; into negative string integer
	_LongNegHexArrayToLongInt(lst){
		; known to be Negative so flip the Bits

		iMaxIndex := lst.Count - 1
		b := lst.Item[iMaxIndex]
		;lst.Item[iMaxIndex] := b >> 1

		bArray := MfByteConverter._FlipBytes(lst)

		;~ ; when negative Add 1
		IsAdded := MfByteConverter._AddOneToByteList(bArray, false)
		
		sResult := "-"
		sResult .= MfByteConverter._LongHexArrayToLongInt(bArray)
		return sResult
	}
;{ _IntToHexArray
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
		bArray := new MfByteList()
		ActualBitCount := bitCount // 4
		MaxMinValuCorrect := false
		if (value = 0)
		{
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			return bArray
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
			
			byte := ""
			i := 0
			while i < 2
			{
				if (Result = 0)
				{
					break
				}
				r := Mod(Result, 16)
				Result := Result // 16

				if (r <= 9)
				{
					byte := r . byte
				}
				else if (r = 10)
				{
					byte := "A" . byte
				}
				else if (r = 11)
				{
					byte := "B" . byte
				}
				else if (r = 12)
				{
					byte := "C" . byte
				}
				else if (r = 13)
				{
					byte := "D" . byte
				}
				else if (r = 14)
				{
					byte := "E" . byte
				}
				else
				{
					byte := "F" . byte
				}
				i++
			}
			byte := "0x" . byte
			byte := byte + 0x0
			bArray.Add(byte)
		}
				
		if (IsNegative)
		{
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			;bArray := MfByteConverter._ReverseList(bArray)
			; flip all the bits
			bArray := MfByteConverter._FlipBytes(bArray)

			if (MaxMinValuCorrect = False)
			{
				;~ ; when negative Add 1
				IsAdded := MfByteConverter._AddOneToByteList(bArray)
			}
			;bArray := MfByteConverter._SwapBytes(bArray)
		}
		else ; if (IsNegative)
		{
			; add zero's to end of postivie array
			while (bArray.Count * 2) < ActualBitCount
			{
				bArray.Add(0)
			}
			;bArray := MfByteConverter._ReverseList(bArray)
			;bArray := MfByteConverter._SwapBytes(bArray)
			
		}
		return bArray
	}
; End:_IntToHexArray ;}
;{ _FlibBytes
	_FlipBytes(lst) {
		bArray := new MfByteList()
		iMaxIndex := lst.Count - 1
		for i, b in lst
		{

			Hex1 := MfByteConverter._GetFirstHexNumber(b)
			Hex2 := MfByteConverter._GetSecondHexNumber(b)

			bInfo1 := MfNibConverter.HexBitTable[Hex1]
			bInfo2 := MfNibConverter.HexBitTable[Hex2]
			
			strHex := MfString.Format("0x{0}{1}", bInfo1.HexFlip, bInfo2.HexFlip)
			hex := strHex + 0x0
			bArray.Add(hex)
		}
		return bArray
	}
; End:_FlibBytes ;}
	
;{ _LongIntStringToHexArray
/*
	Method: _LongIntStringToHex()
		Converts Unsigned Integer String of numbers to Hex
	Parameters:
		strN
			String Unsigned Integer Number
	Returns:
		The the representation of strN as MfByteList of hex values in Litte Endian format
*/	
	_LongIntStringToHexArray(strN, bitCount = 64) {
		if ((bitCount > 0) && (Mod(bitCount, 4)))
		{
			ex := new MfArgumentException(MfEnvironment.Instance.GetResourceString("Argument_Value_Not_Divisable_By", "4"), "bitCount")
			ex.SetProp(A_LineFile, A_LineNumber, A_ThisFunc)
			throw ex
		}

		nibList := MfNibConverter._LongIntStringToHexArray(strN, bitCount)
		return MfNibConverter.ToByteList(nibList)
	}
; End:_LongIntStringToHexArray ;}
;{ _AddOneToByteList
	; adds one to the value of lst only if there
	; is no carry.
	; returns true is value of one was added otherwise false
	; If AddToFront is true then value is added at the beginning Of
	; the list otherwise at the end of the list.
	_AddOneToByteList(byref bArray, AddToFront = true) {
		
		IsAdded := false
		if ( AddToFront = true)
		{
			i := 0
			While i < bArray.Count
			{
				b := bArray.Item[i]
				if (b = 255)
				{
					bArray.Item[i] := 0
					i++
					continue
				}

				b++
				bArray.Item[i] := b

				IsAdded := true
				break
			}
		}
		else
		{
			i := bArray.Count - 1
			While i >= 0
			{
				b := bArray.Item[i]
				if (b = 255)
				{
					bArray.Item[i] := 0
					i--
					continue
				}

				b++
				bArray.Item[i] := b

				IsAdded := true
				break
			}
		}
		return IsAdded
	}
; End:_AddOneToByteList ;}
;{ _SwapBytes
	_SwapBytes(lst) {
		lstSwap := new MfByteList()

		i := lst.Count - 1
		while i >= 0
		{
			lstSwap.Add(lst.Item[i])
			i--
		}
		return lstSwap
	}
; End:_SwapBytes ;}
;{ _RemoveLeadingZeros
	;//Is removing leading zeros from an LongInt String. If the String holds
	;//an leading Minus it is kept -0000123 => -123 and 00985 => 985
	_RemoveLeadingZeros(ByRef LongIntString) {
		local LCh, ZCh, WS
		WS = %LongIntString%
		StringLeft, LCh, WS, 1 
		if (LCh = "-")
		 StringTrimLeft, WS, WS, 1
		 loop
		 {
		 	StringLeft, ZCh, WS, 1 
		 	if (ZCh = "0")
		 	StringTrimLeft, WS, WS, 1
		 	 else
		 	 break  
		}
		If (WS = "")   ;//If it is empty now make it 0
		 	WS = 0
		if (LCh = "-") ;//Add minus again if there was one
			WS = -%WS%
		LongIntString = %WS% ;//returns result BYREF !!!!
	}

; 	End:_LongIntStringDivide ;}
;{ 	_LongIntStringDivide
	_LongIntStringDivide(dividend, divisor, ByRef remainder) {
		q := ""
		sNum := ""
		iLength := StrLen(dividend)
		cMod := 0
		remainder := 0
		loop, parse, dividend
		{
			sNum .= A_LoopField
			cNum := sNum + 0 ; convert to int
			if ( (cNum = 0) && (A_Index > 1) && (A_Index < iLength))
			{
				q .= "0"
				sNum := ""
				continue
			}
			if ( (cNum < divisor) && (A_Index < iLength) )
			{
				if (A_Index > 1)
				{
					q .= "0"
				}
				continue
			}
			cQ := cNum // divisor
			q .= cQ . ""
			cMod := Mod(cNum, divisor)
			if (cMod = 0 )
			{
				sNum := ""
			}
			else
			{
				sNum := cMod . ""
			}
			
		}
		remainder := cMod
		MfBinaryConverter._RemoveLeadingZeros(q)
		return q
	}
; End:_RemoveLeadingZeros ;}
;{ _ReverseList
	_ReverseList(lst) {
		iCount := lst.Count
		bArray := new MfByteList()
		while iCount > 0
		{
			index := iCount -1
			bArray.Add(lst.Item[index])
			iCount --
		}
		return bArray
	}
; End:_ReverseList ;}
;{ _FloatToInt64
	_FloatToInt64(input) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(input, Var, 0, "Double" ) ; Input as Float
		retval := NumGet(Var, 0, "Int64") ; Retrieve it as 'Signed Integer 64'
		return retval
	}
; End:_FloatToInt64 ;}
;{ _Int64ToFloat
	_Int64ToFloat(input) {
		VarSetCapacity(Var, 8, 0)       ; Variable to hold integer
		NumPut(input, Var, 0, "Int64" ) ; Input as Float
		retval := NumGet(Var, 0, "Double") ; Retrieve it as 'Signed Integer 64'
		return retval
	}
; End:_Int64ToFloat ;}

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
				Returns True
		*/
		IsLittleEndian[]
		{
			get {
				return true
			}
			set {
				ex := new MfNotSupportedException(MfEnvironment.Instance.GetResourceString("NotSupportedException_Readonly_Property"))
				ex.SetProp(A_LineFile, A_LineNumber, "IsLittleEndian")
				Throw ex
			}
		}
	; End:IsLittleEndian ;}

}