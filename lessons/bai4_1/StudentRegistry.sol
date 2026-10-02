// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Bài 4.1 – Mapping, Struct, Array
/// @notice Sổ đăng ký sinh viên: lưu thông tin theo địa chỉ ví bằng mapping + struct
contract StudentRegistry {
    // ---------------------------------------------------------
    // 1. STRUCT: gom nhóm dữ liệu của một sinh viên
    // ---------------------------------------------------------
    struct Student {
        string name; // tên sinh viên
        uint age; // tuổi
        bool isRegistered; // đã đăng ký hay chưa
    }

    // ---------------------------------------------------------
    // 2. MAPPING: students[địa chỉ ví] = thông tin sinh viên
    //    Giá trị mặc định của 1 địa chỉ chưa đăng ký:
    //    name = "", age = 0, isRegistered = false
    // ---------------------------------------------------------
    mapping(address => Student) private students;

    // ---------------------------------------------------------
    // 3. ARRAY: danh sách địa chỉ đã đăng ký (thứ tự đăng ký)
    //    Dùng để minh hoạ cách duyệt toàn bộ danh sách sinh viên
    // ---------------------------------------------------------
    address[] public registeredAddresses;

    // Sự kiện phát ra khi có sinh viên đăng ký thành công
    event StudentRegistered(address indexed user, string name, uint age);

    // Số lượng sinh viên đã đăng ký
    function getRegisteredCount() public view returns (uint) {
        return registeredAddresses.length;
    }

    // ---------------------------------------------------------
    // Đăng ký bản thân: mỗi ví chỉ được đăng ký 1 lần
    // ---------------------------------------------------------
    function register(string memory name, uint age) public {
        require(bytes(name).length > 0, "StudentRegistry: name khong duoc rong");
        require(age > 0, "StudentRegistry: age phai lon hon 0");
        require(age <= 150, "StudentRegistry: age khong hop le");
        require(
            !students[msg.sender].isRegistered,
            "StudentRegistry: ban da dang ky truoc do"
        );

        students[msg.sender] = Student({
            name: name,
            age: age,
            isRegistered: true
        });

        registeredAddresses.push(msg.sender);

        emit StudentRegistered(msg.sender, name, age);
    }

    // ---------------------------------------------------------
    // Đọc thông tin sinh viên theo địa chỉ ví
    // ---------------------------------------------------------
    function getStudent(address user)
        public
        view
        returns (string memory name, uint age, bool isRegistered)
    {
        Student storage s = students[user];
        return (s.name, s.age, s.isRegistered);
    }

    // Kiểm tra sinh viên đã đăng ký hay chưa
    function isStudentRegistered(address user) public view returns (bool) {
        return students[user].isRegistered;
    }

    // Đọc thông tin sinh viên tại vị trí thứ index trong mảng
    // (minh hoạ cách truy cập phần tử của array)
    function getStudentAt(uint index)
        public
        view
        returns (address user, string memory name, uint age)
    {
        require(index < registeredAddresses.length, "StudentRegistry: index khong hop le");

        address addr = registeredAddresses[index];
        Student storage s = students[addr];
        return (addr, s.name, s.age);
    }
}
