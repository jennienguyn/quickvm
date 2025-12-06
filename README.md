# QuickVM

![Static Badge](https://img.shields.io/badge/Project-QuickVM-blue)
![Static Badge](https://img.shields.io/badge/License-MIT-green)
![Static Badge](https://img.shields.io/badge/Status-Đang_phát_triển-orange)
![Static Badge](https://img.shields.io/badge/Shell-Bash-yellow)

QuickVM là script Bash giúp tạo nhanh máy ảo sử dụng QEMU/KVM và VirtIO.

Dự án đang trong quá trình xây dựng.

---

## Chức năng dự kiến
- Tạo máy ảo Windows Server 2012 R2 tự động  
- Cho chọn RAM, CPU và dung lượng ổ đĩa  
- Hỗ trợ VirtIO drivers  
- Menu đơn giản:
  - Cài đặt VM
  - Chạy VM
  - Reset VM  
- Hoạt động trên các bản phân phối Linux hỗ trợ KVM

---

## Cài đặt
```bash
git clone https://github.com/jennienguyn/vm.git
cd vm
chmod +x quickvm.sh
````

---

## Sử dụng

```bash
chmod +x quickvm.sh
./quickvm.sh
```

---

## License

Dự án phát hành theo MIT License.
