USE QuanLyBanHang
GO

-- câu 1: Liệt kê danh sách nhân viên kèm chức vụ
SELECT nv.id_nv,nv.ten,nv.tuoi,nv.dia_chi,nv.gioi_tinh,cv.ten
FROM dbo.NhanVien AS nv JOIN dbo.ChucVu AS cv
ON cv.id_cv = nv.id_cv
--WHERE cv.id_cv='CV01' -- Nhân viên bán hàng
WHERE cv.id_cv='CV02' -- Nhân viên nhập hàng
-- Câu 2: In ra hóa đơn bán hàng (của tất cả các hóa đơn hoặc của từng hóa đơn )
SELECT dbo.HoaDon.id_hd AS [Mã HD],dbo.HoaDon.id_nv AS [Mã NV],dbo.SanPham.ten AS [Tên SP],
dbo.SanPham.gia AS Giá,dbo.Mua.so_luong AS [Số lượng],
dbo.HoaDon.ngay AS [Ngày bán],dbo.HoaDon.tong_sp AS [Tổng SP],
dbo.HoaDon.tong_tien AS [Tổng tiền]
FROM dbo.HoaDon
LEFT JOIN dbo.SanPham ON SanPham.id_hd = HoaDon.id_hd
JOIN dbo.Mua ON Mua.id_sp = SanPham.id_sp
--WHERE HoaDon.id_hd='HD01'
--where dbo.HoaDon.ngay='2022-02-12'
ORDER BY HoaDon.id_hd

-- Câu 3: Liệt kê số sản phẩm mỗi nhân viên bán được
SELECT dbo.HoaDon.id_nv AS [Mã NV],sum(dbo.HoaDon.tong_sp) AS [Số sản phẩm]
FROM dbo.HoaDon
GROUP BY id_nv

-- Câu 4: Liệt kê những khách hàng mua hàng có địa chỉ ở Hà Nội và số lượng sản phẩm và tổng tiền
SELECT dbo.KhachHang.ten AS [tên khách hàng],dbo.KhachHang.dia_chi AS [địa chỉ],SUM(dbo.Mua.so_luong) AS [số sản phẩm],
dbo.HoaDon.tong_tien AS [Tổng tiền mua]
FROM dbo.KhachHang
JOIN dbo.Mua ON Mua.id_KH = KhachHang.id_KH
JOIN dbo.SanPham ON SanPham.id_sp = Mua.id_sp
JOIN dbo.HoaDon ON HoaDon.id_hd = SanPham.id_hd
WHERE dbo.KhachHang.dia_chi LIKE 'Hà N%'
GROUP BY dbo.KhachHang.ten,dbo.KhachHang.dia_chi,tong_tien
ORDER BY dbo.KhachHang.ten

-- Câu 5: Liệt kê danh sách các mặt hàng đã nhập kèm tên nhân viên, chi nhánh và nhà cung cấp
SELECT dbo.NhanVien.id_nv AS [Mã nv],dbo.NhanVien.ten AS [Tên nhân viên],
dbo.SanPham.id_sp AS [Mã sp],dbo.SanPham.ten AS [Tên sản phẩm],
dbo.ChiNhanh.ten AS [Tên chi nhánh],dbo.NhaCC.ten AS [Tên nhà cung cấp]
FROM dbo.NhanVien
JOIN dbo.NhapHang ON NhapHang.id_nv = NhanVien.id_nv
JOIN dbo.SanPham ON SanPham.id_sp = NhapHang.id_sp
JOIN dbo.ChiNhanh ON ChiNhanh.id_cn = NhapHang.id_cn
JOIN dbo.NhaCC ON NhaCC.id_nhacc = ChiNhanh.id_nhacc

-- Câu 6: Liệt kê các mặt hàng tiêu dùng và mặt hàng đồ gia dụng
--hang tieu dung
SELECT td.id_sp_Hangtd AS [ID hàng tiêu dùng],sp.ten AS [Tên hàng tiêu dùng],td.loai AS Loại
FROM dbo.HangTieuDung AS td
JOIN dbo.SanPham AS sp ON sp.id_sp = td.id_sp_Hangtd
-- do gia dung
SELECT gd.id_sp_DoGd AS [ID hàng tiêu dùng],sp.ten AS [Tên hàng tiêu dùng],gd.loai AS Loại
FROM dbo.DoGiaDung AS gd
JOIN dbo.SanPham AS sp ON sp.id_sp = gd.id_sp_DoGd

-- Câu 7: Liệt kê danh sách khách hàng tham gia mua đồ 
SELECT DISTINCT buy.id_KH AS [Mã KH],cus.ten AS [Tên KH],cus.tuoi AS Tuổi,cus.dia_chi AS [Địa chỉ],sdt.sdt
FROM dbo.Mua AS buy, dbo.KhachHang AS cus,dbo.KhachHangSdt AS sdt
WHERE buy.id_KH=cus.id_KH AND cus.id_KH=sdt.id_KH
ORDER BY buy.id_KH

-- Câu 8: Liệt kê nhân top 3 nhân viên bán được nhiều sản phẩm nhất
SELECT A.[Mã NV],dbo.NhanVien.ten AS [Tên NV],A.[Số sản phẩm]
FROM (
	SELECT TOP 3 dbo.HoaDon.id_nv AS [Mã NV],sum(dbo.HoaDon.tong_sp) AS [Số sản phẩm]
	FROM dbo.HoaDon
	GROUP BY dbo.HoaDon.id_nv
	ORDER BY [Số sản phẩm] DESC) AS A,dbo.NhanVien
	WHERE A.[Mã NV]=dbo.NhanVien.id_nv

-- Thưởng 100000  cho top 3 nhân viên bán được nhiều sản phẩm nhất
-- thêm cột bonus vào bảng nhân viên
ALTER TABLE dbo.NhanVien
ADD bonus INT

UPDATE dbo.NhanVien
SET bonus=100000
WHERE id_nv IN
	(SELECT A.[Mã NV]
	FROM (
		SELECT TOP 3 dbo.HoaDon.id_nv AS [Mã NV],sum(dbo.HoaDon.tong_sp) AS [Số sản phẩm]
		FROM dbo.HoaDon
		GROUP BY id_nv
		ORDER BY [Số sản phẩm] DESC) AS A
		 )
SELECT * FROM dbo.NhanVien
WHERE bonus IS NOT NULL

-- Câu 9: Liệt kê khách hàng chi nhiều tiền nhất mua sản phẩm
SELECT DISTINCT TOP 1 dbo.KhachHang.id_KH AS [Mã KH], dbo.KhachHang.ten AS [Tên KH]
,dbo.HoaDon.tong_sp AS [Tổng SP],
dbo.HoaDon.tong_tien AS [Tổng tiền]
FROM dbo.KhachHang
JOIN dbo.Mua ON Mua.id_KH = KhachHang.id_KH
JOIN dbo.SanPham ON SanPham.id_sp = Mua.id_sp
JOIN dbo.HoaDon ON HoaDon.id_hd = SanPham.id_hd
ORDER BY tong_tien DESC

-- Câu 10: Liệt kê khách hàng chỉ mua 1 sản phẩm
SELECT DISTINCT dbo.KhachHang.id_KH AS [Mã KH], dbo.KhachHang.ten AS [Tên KH],dbo.HoaDon.tong_sp AS [Tổng SP],
dbo.HoaDon.tong_tien AS [Tổng tiền]
FROM dbo.KhachHang
JOIN dbo.Mua ON Mua.id_KH = KhachHang.id_KH
JOIN dbo.SanPham ON SanPham.id_sp = Mua.id_sp
JOIN dbo.HoaDon ON HoaDon.id_hd = SanPham.id_hd
WHERE tong_sp=1
ORDER BY tong_sp

-- Câu 11: Liệt kê mã NV,tên nhân viên tham gia nhập hàng và số lượng sp nhập về của từng nhân viên
SELECT dbo.NhapHang.id_nv AS [Mã NV],dbo.NhanVien.ten AS [Tên NV],
SUM(dbo.NhapHang.so_luong) AS [Số lượng]
FROM dbo.NhapHang, dbo.NhanVien
WHERE NhapHang.id_nv=NhanVien.id_nv
GROUP BY NhapHang.id_nv,ten 

-- Câu 12: Liệt kê loại mặt hàng tiêu dùng được mua nhiều nhất
SELECT TOP 1 td.id_sp_Hangtd AS [ID Hàng tiêu dùng], sp.ten AS [Tên], 
td.loai AS [Loại], 
dbo.HoaDon.tong_sp as [Tổng sản phẩm]
FROM dbo.HangTieuDung AS td
JOIN dbo.SanPham AS sp ON sp.id_sp = td.id_sp_Hangtd
JOIN dbo.Mua AS mua ON mua.id_sp = sp.id_sp
JOIN dbo.HoaDon ON HoaDon.id_hd = sp.id_hd
ORDER BY [Tổng sản phẩm] DESC

-- Câu 13: Liệt kê loại mặt hàng đồ gia dụng được mua ít nhất
SELECT TOP 1 gd.id_sp_DoGd AS [ID Đồ gia dụng], sp.ten AS [Tên], 
gd.loai AS [Loại], 
dbo.HoaDon.tong_sp as [Tổng sản phẩm]
FROM dbo.DoGiaDung AS gd
JOIN dbo.SanPham AS sp ON sp.id_sp = gd.id_sp_DoGd
JOIN dbo.Mua AS mua ON mua.id_sp = sp.id_sp
JOIN dbo.HoaDon ON HoaDon.id_hd = sp.id_hd
ORDER BY [Tổng sản phẩm], [ID Đồ gia dụng]

-- Câu 14: Liệt kê các chi nhánh có địa chỉ X (X = Dương Nội - Hà Đông)
SELECT CN.id_cn AS [ID Chi nhánh], CN.ten AS [Tên chi nhánh], CN.dia_chi AS [Địa chỉ], NCC.ten AS [Nhà cung cấp]
FROM dbo.ChiNhanh AS CN
JOIN dbo.NhaCC AS NCC ON NCC.id_nhacc = CN.id_nhacc
WHERE CN.dia_chi = N'Dương Nội - Hà Đông'

-- Câu 15: Liệt kê các nhân viên từ 20 tuổi trở lên
SELECT NV.id_nv AS [ID Nhân viên], NV.ten AS [Tên], NV.gioi_tinh AS [Giới tính], NV.tuoi AS [Tuổi], 
NV.dia_chi AS [Địa chỉ], CV.ten AS [Chức vụ]
FROM dbo.NhanVien AS NV 
JOIN dbo.ChucVu AS CV ON CV.id_cv = NV.id_cv
WHERE NV.tuoi >= 20
ORDER BY NV.tuoi DESC

-- Câu 16: Liệt kê số điện thoại liên hệ của các khách hàng nam có địa chỉ ở Hà Nội
SELECT SDT.sdt AS [Số điện thoại], KH.id_KH AS [ID], KH.ten AS [Tên]
FROM KhachHangSdt AS SDT
JOIN KhachHang AS KH ON KH.id_KH = SDT.id_KH
WHERE KH.gioi_tinh = N'Nam' AND KH.dia_chi = N'Hà Nội'

-- Câu 17: Liệt kê các khu vực (địa chỉ) của khách hàng có số hóa đơn mua hàng giảm dần
SELECT KH.dia_chi AS [Khu vực], COUNT(HD.id_hd) AS [Số hóa đơn]
FROM dbo.KhachHang AS KH
LEFT JOIN dbo.Mua AS MUA ON MUA.id_KH = KH.id_KH
LEFT JOIN dbo.SanPham AS SP ON SP.id_sp = MUA.id_sp
LEFT JOIN dbo.HoaDon AS HD ON HD.id_hd = SP.id_hd
GROUP BY KH.dia_chi 
ORDER BY [Số hóa đơn] DESC

-- Câu 18: Thống kê độ tuổi trung bình của nhân viên bán hàng
SELECT AVG(NV.tuoi) AS [Trung bình độ tuổi nhân viên], AVG(KH.tuoi) AS [Trung bình độ tuổi khách hàng]
FROM dbo.NhanVien AS NV, dbo.KhachHang AS KH

