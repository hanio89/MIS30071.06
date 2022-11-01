--Bai tap sql:

/* CÁC BÀI TẬP DƯỚI ĐÂY CHỈ MANG TÍNH CHẤT THAM KHẢO, CHƯA BIẾT ĐƯỢC ĐÚNG SAI 100% */

--Thu Tuc
use bank --(Tên cơ sở dữ liệu ngân hàng đã tạo để làm bài tập)
GO
--1. Trả về tên chi nhánh ngân hàng nếu biết mã của nó. 

	--Cách 1
create proc TEN_CHI_NHANH_KHACHHANG (@MACH nvarchar(20), @TENCHINHANH nvarchar(50) output)
as
BEGIN
    set @TENCHINHANH = (select Branch.BR_name
                        from Branch
                        WHERE @MACH = Branch.BR_id)
END

DECLARE @count nvarchar(50)
exec TEN_CHI_NHANH_KHACHHANG 'VB001', @count out
print @count
GO

	--Cách 2
CREATE PROC TenChiNhanh @Brid CHAR(10)
AS 
BEGIN
		SELECT BR_name FROM Branch
		WHERE BR_id = @Brid
END


DECLARE @b NVARCHAR(100), @brname NVARCHAR(100);
EXEC TenChiNhanh @Brid='VB002', @Brname = @B OUTPUT
PRINT @b
GO
--2. Trả về tên, địa chỉ và số điện thoại của khách hàng nếu biết mã khách.
	
	--Cách 1
create proc TEN_DIACHI_SDT_KH (@MAKH varchar(10), @TEN nvarchar(50) output,@ADD nvarchar(100) output, @SDT varchar(15) output)
AS
BEGIN
    set @TEN = (select REVERSE(SUBSTRING(REVERSE(Cust_name), 1, CHARINDEX(' ', REVERSE(Cust_name)) - 1))
                from customer
                where customer.Cust_id = @MAKH )
    set @ADD = (select cust_ad 
                from customer
                where customer.Cust_id = @MAKH )
    set @SDT = (select cust_phone 
                from customer
                where customer.Cust_id = @MAKH )
END

DECLARE @count1 NVARCHAR(50), @count2 NVARCHAR(50), @count3 VARCHAR(15)
exec TEN_DIACHI_SDT_KH '000001', @count1 out, @count2 out, @count3 out 
print @count1 
print @count2 
print @count3
GO

	--Cách 2
CREATE PROC Info @ma_khach VARCHAR(10)
AS
BEGIN
		SELECT Cust_name, Cust_ad, Cust_phone FROM customer
		WHERE Cust_id = @ma_khach
END

EXEC Info '000001' -- nchar(10)
GO


--3. In ra danh sách khách hàng của một chi nhánh cụ thể nếu biết mã chi nhánh đó. 

	--Cách 1
create proc DANH_SACH_KH (@MANH nvarchar(50),@MAKH NVARCHAR(20) output, @HOVATEN NVARCHAR(50) output)
AS
BEGIN
    set @MAKH = (select cust_id 
                FROM customer join Branch on customer.Br_id = Branch.BR_id
                where @MANH = Branch.BR_id)
    set @HOVATEN = (select Cust_name
                FROM customer join Branch on customer.Br_id = Branch.BR_id
                where @MANH = Branch.BR_id)
END
GO

DECLARE @count1 NVARCHAR(20), @count2 NVARCHAR(50)
exec DANH_SACH_KH 'VB001', @count1 out, @count2 out 
print @count1
print @count2
GO

	--Cách 2
CREATE PROC DsChiNhanh @MaChiNhanh VARCHAR(10)
AS
BEGIN
		SELECT Cust_id, Cust_name
		FROM Branch JOIN customer ON customer.Br_id = Branch.BR_id
		WHERE Branch.BR_id = @MaChiNhanh
END 

EXEC DsChiNhanh @MaChiNhanh = 'VB005' -- varchar(10)
GO

--4. Kiểm tra một khách hàng nào đó đã tồn tại trong hệ thống CSDL của ngân hàng chưa nếu biết: họ tên, số điện thoại của họ. 
--Đã tồn tại trả về 1, ngược lại trả về 0 

	--Cách 1
CREATE PROC CHECK_KHACH_HANG (@HOVATEN nvarchar(50), @SDT varchar(15), @CHECK varchar(1))
AS
BEGIN
    DECLARE @MAKH varchar(10)
    set @MAKH = (select Cust_id from customer
                where @HOVATEN = customer.Cust_name and @SDT = customer.Cust_phone)
    if @MAKH in (select Cust_id from customer
                where @HOVATEN = customer.Cust_name and @SDT = customer.Cust_phone)
        print 1
    ELSE
        print 0

END
GO

DECLARE @count varchar(1)
exec CHECK_KHACH_HANG N'Nguyen Ngo Diem Quynh','01283388103', @count
print @count
GO

	--Cách 2
CREATE PROC CheckAcc @HoTen NVARCHAR(100), @SDT VARCHAR(11), @ret NVARCHAR(50) OUT
AS
BEGIN
		DECLARE @check INT = 0
		IF @HoTen IN (SELECT Cust_name FROM customer)
			SET @check = @check + 1
		IF @SDT IN (SELECT Cust_phone FROM customer)
			SET @check = @check + 1
		IF @check = 2
			SET @ret = 1
		ELSE 
			SET @ret = 0
END
GO 

DECLARE @ret NVARCHAR(50);
EXEC CheckAcc @HoTen = N'Huy Ngu Ngok',      -- nvarchar(100)
                  @SDT = '01283388103',         -- varchar(11)
                  @ret = @ret OUTPUT -- nvarchar(50)
PRINT @ret
GO

--5. Cập nhật số tiền trong tài khoản nếu biết mã số tài khoản và số tiền mới. 
--Thành công trả về 1, thất bại trả về 0 

	--Cách 1
CREATE proc CAP_NHAT_SO_TIEN (@MATK nvarchar(10), @TIENMOI nvarchar(50), @CAPNHAT nvarchar(50) output)
AS
BEGIN
    DECLARE @TIEN INT
    set @TIEN = (select account.ac_balance
                from account
                where account.Ac_no = @MATK)
    IF @TIEN <> @TIENMOI
        UPDATE account
        set @TIEN = @TIENMOI;
        print 1
    if @TIEN = @TIENMOI
        print 0

END
GO

	--Cách 2
CREATE PROC CapNhatTien @STK VARCHAR(10), @SoTien INT, @ret NVARCHAR(50) OUT
AS
BEGIN TRY 
		UPDATE account
		SET ac_balance =  ac_balance + @SoTien
		WHERE Ac_no = @STK
		SET @ret = 1
END TRY 
BEGIN CATCH
		SET @ret = 0
END CATCH

DECLARE @ret NVARCHAR(50);
EXEC CapNhatTien @STK = '1000000001',         -- varchar(10)
                     @SoTien = -100000000,       -- int
                     @ret = @ret OUTPUT -- nvarchar(50)
PRINT @ret
GO

--6. Cập nhật địa chỉ của khách hàng nếu biết mã số của họ. Thành công trả về 1, thất bại trả về 0 
CREATE PROC CapNhatDiaChi @MS VARCHAR(10), @ret NVARCHAR(50) OUT
AS
BEGIN TRY 
		UPDATE customer
		SET Cust_ad = '.....'
		WHERE Cust_id = @MS
		SET @ret = 1
END TRY 
BEGIN CATCH
		SET @ret = 0
END CATCH
GO

--7. Trả về số tiền có trong tài khoản nếu biết mã tài khoản. 

	--Cách 1
create proc TRA_VE_SO_TIEN (@MATK nvarchar(20), @SODU int output)
as 
BEGIN
    set @SODU = (select ac_balance
                from account
                where account.Ac_no = @MATK)
        
END

DECLARE @count INT
exec TRA_VE_SO_TIEN '1000000001', @count out 
print @count

select * from account
GO

	--Cách 2
CREATE PROC SoTien @MaTK VARCHAR(10), @kqtien NVARCHAR(100) OUT
AS 
BEGIN
		SELECT @kqtien = ac_balance
		FROM account
		WHERE Ac_no = @MaTK
END


SELECT * FROM account

DECLARE @k NVARCHAR(100)
EXEC SoTien @MaTK = '1000000001', @kqtien = @k OUT
PRINT @k
GO 

--8. Trả về số lượng khách hàng, tổng tiền trong các tài khoản nếu biết mã chi nhánh. 
CREATE PROC SLKhachHang_TongKhachHang (@MACN nvarchar(20), @SLKH int output, @TONG int output)
AS
BEGIN
    set @SLKH = (select count(cust_id)
                from customer join Branch on customer.Br_id = Branch.BR_id
                where Branch.BR_id = @MACN
                group by branch.Br_id)
    set @TONG = (select sum(ac_balance)
                from customer join account on customer.Cust_id = account.cust_id
                              join Branch on Branch.BR_id = customer.Br_id
                where @MACN = Branch.BR_id
                group by Ac_no)
END

DECLARE @count1 int , @count2 int
exec SLKhachHang_TongKhachHang 'VB001', @count1 out , @count2 out
print @count1
print @count2
 
	--Cách 2
CREATE PROC Cau8 @MaChiNhanh VARCHAR(10), @SoLuongKhach INT OUT, @TongTien INT OUT
AS
BEGIN
		SELECT @SoLuongKhach = COUNT(A.cust_id), @TongTien = SUM(A.ac_balance)
		FROM account A JOIN customer C ON C.Cust_id = A.cust_id
							JOIN Branch B ON B.BR_id = C.Br_id
		WHERE B.BR_id = @MaChiNhanh						
END
			
DECLARE @SoLuongKhach INT,
        @TongTien INT;
EXEC Cau8 @MaChiNhanh = 'VB004',                     -- varchar(10)
              @SoLuongKhach = @SoLuongKhach OUTPUT, -- int
              @TongTien = @TongTien OUTPUT          -- int
PRINT @SoLuongKhach
PRINT @TongTien
go

--9. Kiểm tra một giao dịch có bất thường hay không nếu biết mã giao dịch. Giao dịch bất thường: giao dịch gửi diễn ra ngoài giờ hành chính, giao dịch rút diễn ra vào thời điểm 0am  3am 
--input: mã giao dịch
--output: kết quả kiểm tra
create PROC Cau9 @MaGiaoDich VARCHAR(10), @KetQua NVARCHAR(100) OUT
AS
BEGIN	
		DECLARE @time TIME
		SELECT @time = t_time
		FROM transactions
		WHERE t_id = @MaGiaoDich
		SET @KetQua = CASE	WHEN @time BETWEEN '03:00:00' AND '23:59:59' THEN N'Giao dịch bình thường'
							ELSE N'Giao dịch bất thường'
							END 
END	

SELECT * FROM transactions
DECLARE @b NVARCHAR(100)
EXEC Cau9 @MaGiaoDich = '0000000246', @KetQua = @b OUT 
PRINT @b
GO
create proc KTGD @magiaodich varchar(10),@ketqua nvarchar(100) out
as
begin
	declare @time = time
	select @time = t_time 
	from transactions 
	where t_id = @magiaodich
	set @ketqua = case when @time between 
end
-------
create proc kiemtraGDBT (@t_id varchar(50), @ret nvarchar(50) output)
as
begin
	if exists (select t_id from transactions where t_time between '00:00' and '03:00' and t_id=@t_id)
	begin 
		set @ret=N'Giao dịch bất thường'
	end
	else
		set @ret=N'Không có gì bất thường'
end
declare @ret nvarchar(50)
exec kiemtraGDBT '0000000264', @ret out
print @ret

-- 10.Trả về mã giao dịch mới. Mã giao dịch tiếp theo được tính như sau: MAX(mã giao dịch đang có) + 1. Hãy đảm bảo số lượng kí tự luôn đúng với quy định về mã giao dịch
	
	--Cách 1
create proc pCau10 (@maMoi varchar(15) output)
as
begin
	declare @maMax varchar(15), @len varchar(15)
	set @maMax = (select MAX(t_id) from transactions)
	set @maMoi = @maMax + 1
	set @len = (select top 1 LEN(t_id) from transactions)
	set @maMoi = REPLICATE ('0', @len - len(@maMoi)) + @maMoi 
end
go

declare @count varchar(15)
exec pCau10 @count output
print @count
EXEC pCau10 '2022/10/17','12:00','1000000001',1,'1'

--hàm vô hướng
create function fNewID()
returns varchar(10)
as
begin
    declare @maMax int, @len varchar(15), @newID varchar(10)
	set @maMax = (select MAX(t_id) from transactions)
	set @maMoi = @maMax + 1
	set @len = (select top 1 LEN(t_id) from transactions)
	set @maMoi = REPLICATE ('0', @len - len(@maMoi)) + @maMoi 
	return @newID
end

print fnewID()





--11.THAM KHẢO-Thêm một bản ghi vào bảng TRANSACTIONS nếu biết các thông tin ngày giao dịch, thời gian giao dịch, số tài khoản, loại giao dịch, số tiền giao dịch. 
--Công việc cần làm bao gồm:
--a. Kiểm tra ngày và thời gian giao dịch có hợp lệ không. Nếu không, ngừng xử lý 
--b. Kiểm tra số tài khoản có tồn tại trong bảng ACCOUNT không? Nếu không, ngừng xử lý 
--c. Kiểm tra loại giao dịch có phù hợp không? Nếu không, ngừng xử lý 
--d. Kiểm tra số tiền có hợp lệ không (lớn hơn 0)? Nếu không, ngừng xử lý
--e. Tính mã giao dịch mới
--f. Thêm mới bản ghi vào bảng TRANSACTIONS
--g. Cập nhật bảng ACCOUNT bằng cách cộng hoặc trừ số tiền vừa thực hiện giao dịch tùy theo loại giao dịch

go
CREATE proc Update_ST (@t_date date, @t_time time, @ac_no varchar(10),@t_type int,@t_amount numeric(15,0)) 
as
begin
	declare @newID varchar(10), @max int, @temp varchar(10)

	if @t_date > getdate() or @t_time between '00:00' and '3:00'
	begin
		print N'Thời gian GD không hợp lệ'
		return
	end
	else if not exists (select ac_no from account where ac_no=@ac_no)
	begin
		print N'Tài khoản không tồn tại'
		return
	end
	else if @t_amount <=0 
	begin 
	print N'Số tiền không hợp lệ'
	return
end

	set @max = (select max(cast(t_id as int)) from transactions)
	set @temp = cast(@max+1 as varchar)
	set @newID = replicate('0',10-len(@temp)) + @temp

	insert into transactions values(@newID,@t_type,@t_amount,@t_date,@t_time,@ac_no)

	if @@ROWCOUNT > 0
	begin 
		if @t_type=0
		begin
			update account
			set ac_balance=ac_balance-@t_amount
			where ac_no=@ac_no
		end
	end
end

exec Update_ST '2022/10/17','12:00','1000000001',1,'1'

--12 THAM KHẢO
go
create proc pCau12 (@makh varchar(15), @loaitk varchar(1), @sotien numeric(15,0), @trave nvarchar(50) output)
as
begin
--a
	declare @dem int = 0 --gán int =0 thì để nếu null thì = 0
	set @dem = (select COUNT(Cust_id) from customer where Cust_id = @makh)
	if @dem <= 0
	begin
		set @trave = N'Mã khách chưa tồn tại'
		return
	end
	--b
	if @loaitk not in ('1','0')
	begin
		set @trave = N'Loại tài khoản không hợp lệ'
		return
	end
--c
	
	if @sotien is null
		set @sotien = 50000
	else if @sotien < 0
	begin
		set @trave = N'Số tiền không hợp lệ'
		return
	end
	--d
	declare @idMoi varchar(15), @len varchar(15), @idMax varchar(15)
	set @idMax = (select MAX(Ac_no) from account)
	set @idMoi = @idMax + 1
	--print @idMoi
	--e
	insert into account values (@idMoi, @sotien,@loaitk,@makh)
	if @@ROWCOUNT > 0
		set @trave = N'Thêm mới thành công'
	else
		set @trave = N'Thêm mới thất bại'
end
go
--testing
declare @trave nvarchar(50)
exec pCau12 '000001','1','500000', @trave output
print @trave

--12. Thêm mới một tài khoản nếu biết: mã khách hàng, loại tài khoản, số tiền trong tài khoản. Bao gồm những công việc sau:
--a. Kiểm tra mã khách hàng đã tồn tại trong bảng CUSTOMER chưa? Nếu chưa, ngừng xử lý 
--b. Kiểm tra loại tài khoản có hợp lệ không? Nếu không, ngừng xử lý 
--c. Kiểm tra số tiền có hợp lệ không? Nếu NULL thì để mặc định là 50000, nhỏ hơn 0 thì ngừng xử lý. 
--d. Tính số tài khoản mới. Số tài khoản mới bằng MAX(các số tài khoản cũ) + 1 
--e. Thêm mới bản ghi vào bảng ACCOUNT với dữ liệu đã có.
go
create proc pCau12 (@makh varchar(15), @loaitk varchar(1), @sotien numeric(15,0), @trave nvarchar(50) output)
as
begin
--a
	declare @dem int = 0 
	set @dem = (select COUNT(Cust_id) from customer where Cust_id = @makh)
	if @dem <= 0
	begin
		set @trave = N'Mã khách chưa tồn tại'
		return
	end
--b
 declare @dem int = 0 
	set @dem = (select COUNT(Cust_id) from customer where Cust_id = @makh)
	if @dem <= 0
	begin
		set @trave = N'Mã khách chưa tồn tại'
		return
	end
	--b
	if @loaitk not in ('1','0')
	begin
		set @trave = N'Loại tài khoản không hợp lệ'
		return
	end


	



