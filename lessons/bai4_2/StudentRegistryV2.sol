// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

/// @title Bài 4.2 - StudentRegistryV2
/// @notice Chỉ owner được thêm sinh viên và phát event khi thêm thành công
contract StudentRegistryV2 {
    // Struct lưu thông tin sinh viên
    struct Student {
        string name;
        uint age;
        bool isRegistered;
    }

    // Mapping lưu thông tin theo địa chỉ ví
    mapping(address => Student) private students;

    // Địa chỉ owner
    address public owner;

    // Event khi thêm sinh viên thành công
    event StudentAdded(address indexed user, string name, uint age);

    // Modifier giới hạn quyền owner
    modifier onlyOwner() {
        require(
            msg.sender == owner,
            "StudentRegistryV2: chi owner moi duoc phep"
        );
        _;
    }

    // Người deploy trở thành owner
    constructor() {
        owner = msg.sender;
    }

    // Chỉ owner được thêm sinh viên
    function registerStudent(
        address user,
        string memory name,
        uint age
    ) public onlyOwner {
        require(user != address(0), "Dia chi khong hop le");
        require(bytes(name).length > 0, "Ten khong duoc rong");
        require(age > 0 && age <= 150, "Tuoi khong hop le");
        require(
            !students[user].isRegistered,
            "Sinh vien da ton tai"
        );

        students[user] = Student({
            name: name,
            age: age,
            isRegistered: true
        });

        emit StudentAdded(user, name, age);
    }

    // Đọc thông tin sinh viên
    function getStudent(address user)
        public
        view
        returns (
            string memory name,
            uint age,
            bool isRegistered
        )
    {
        Student storage s = students[user];
        return (s.name, s.age, s.isRegistered);
    }

    // Kiểm tra sinh viên đã đăng ký hay chưa
    function isStudentRegistered(address user)
        public
        view
        returns (bool)
    {
        return students[user].isRegistered;
    }
}
