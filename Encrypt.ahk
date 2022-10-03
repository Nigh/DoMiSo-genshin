
; 检查文本是否包含明文信息分段
Encrypt_dms_valid(v)
{
	Loop, Parse, v, `n, `r
	{
		IfInString, A_LoopField, ======
		{
			return 1
		}
	}
	return 0
}

is_dms_file(f)
{
	filehead:=[0x80, 0xFE, 0x64, 0x6F, 0x6D, 0x69, 0x73, 0x6F]
	; 检测合法文件头
	f.Seek(0)
	Try {
		Loop, 8
		{
			if f.ReadUChar()!=filehead[A_Index]
				Throw, error
		}
	} catch e {
		Return 0
	}
	Return 1
}

; 解密
Decrypt_file(f)
{
	enc_key:=[0xAA,0x55,0xDE,0xAD]
	cipher_key:=[0x00,0x00,0x00,0x00]
	plaintext:=""
	ciphertext:=""
	plaintext_len:=0
	ciphertext_len:=0
	f.Seek(8, 1)
	Loop, 4
	{
		cipher_key[A_Index]:=f.ReadUChar()
	}
	plaintext_len:=f.ReadUShort()
	ciphertext_len:=f.ReadUShort()
	; 计算文本密钥
	Loop, % plaintext_len
	{
		r_index:=(A_Index-1)&0x3
		enc_key[r_index+1]^=f.ReadUChar()
	}
	; 计算解密密钥
	Loop, 4
	{
		cipher_key[A_Index]^=enc_key[A_Index]
	}
	f.Seek(16)
	VarSetCapacity(plaintext, plaintext_len, 0x00)
	f.RawRead(plaintext, plaintext_len)
	VarSetCapacity(ciphertext, ciphertext_len, 0x00)
	f.RawRead(ciphertext, ciphertext_len)
	Loop, % ciphertext_len
	{
		r_index:=(A_Index-1)&0x3
		NumPut(NumGet(ciphertext,A_Index-1,"UChar")^cipher_key[r_index+1],ciphertext,A_Index-1,"UChar")
	}
	Return [plaintext, ciphertext]
}

dms_parser(v)
{
	comment:=""
	sheet:=""
	isSheet:=0
	Loop, Parse, v, `n, `r
	{
		IfInString, A_LoopField, ======
		{
			isSheet:=1
			Continue
		}
		if isSheet=0
		{
			comment.=A_LoopField "`r`n"
		}
		Else
		{
			sheet.=A_LoopField "`r`n"
		}
	}
	if isSheet=0
	{
		Return ["", comment]
	}
	Return [comment, sheet]
}

; 加密
Encrypt_dms_enc(v)
{
	filehead:=[0x80, 0xFE, 0x64, 0x6F, 0x6D, 0x69, 0x73, 0x6F]
	head:=""
	VarSetCapacity(head, 16, 0x00)
	plaintext:=""
	ciphertext:=""
	enc_key:=[0xAA,0x55,0xDE,0xAD]
	cipher_key:=[0x00,0x00,0x00,0x00]
	; 提取明文段与密文段
	cipher:=0
	Loop, Parse, v, `n, `r
	{
		IfInString, A_LoopField, ======
		{
			cipher:=1
			Continue
		}
		if cipher=0
		{
			plaintext.=A_LoopField "`r`n"
		}
		Else
		{
			ciphertext.=A_LoopField "`r`n"
		}
	}
	plainLen := VarSetCapacity(plaintext, -1)
	cipherLen := VarSetCapacity(ciphertext, -1)

	; Put明文段raw长度
	NumPut(plainLen, head, 12, "UShort")
	; Put密文段raw长度
	NumPut(cipherLen, head, 14, "UShort")

	; 生成密钥
	Loop, % plainLen
	{
		r_index:=(A_Index-1)&0x3
		enc_key[r_index+1]^=NumGet(plaintext, A_Index-1, "UChar")
	}
	; Put随机密钥
	Loop, 4
	{
		Random, rands, 0x00, 0xFF
		NumPut(rands, head, 7+A_Index, "UChar")
	}
	; 计算加密密钥
	Loop, 4
	{
		cipher_key[A_Index]:=NumGet(head, 7+A_Index, "UChar")^enc_key[A_Index]
	}
	; 使用加密密钥加密密文段
	Loop, % cipherLen
	{
		r_index:=((A_Index-1)&0x3)+1
		NumPut(NumGet(ciphertext,A_Index-1,"UChar")^cipher_key[r_index],ciphertext,A_Index-1,"UChar")
	}
	; 添加文件头
	loop, 8
	{
		NumPut(filehead[A_Index], head, A_Index-1, "UChar")
	}
	; 拼接文件
	output:=""
	head_len:=16
	output_len:=head_len+plainLen+cipherLen
	VarSetCapacity(output,output_len,0x00)
	Loop, % head_len
	{
		NumPut(NumGet(head, A_Index-1, "UChar"), output, A_Index-1, "UChar")
	}
	Loop, % plainLen
	{
		NumPut(NumGet(plaintext, A_Index-1, "UChar"), output, head_len+A_Index-1, "UChar")
	}
	Loop, % cipherLen
	{
		NumPut(NumGet(ciphertext, A_Index-1, "UChar"), output, head_len+plainLen+A_Index-1, "UChar")
	}
	filename:="DoMiSoCipher_" A_Now ".dms"
	File := FileOpen(filename, "w", "UTF-8-RAW")
	File.RawWrite(output, output_len)
	File.Close()
	Return filename
}
