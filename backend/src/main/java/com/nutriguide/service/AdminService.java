package com.nutriguide.service;

import com.nutriguide.dto.UserProfileDto;
import com.nutriguide.model.User;
import com.nutriguide.repository.UserRepository;
import com.nutriguide.exception.ResourceNotFoundException;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class AdminService {
    
    @Autowired
    private UserRepository userRepository;
    
    @Autowired
    private UserService userService;

    public List<UserProfileDto> getAllUsers() {
        return userService.findAll(); // Changed from getAllUsers to findAll
    }
    
    @Transactional
    public UserProfileDto updateUser(Long userId, UserProfileDto userDto) {
        return userService.updateUserByAdmin(userId, userDto); // Changed from updateUser to updateUserByAdmin
    }
    
    @Transactional
    public void deleteUser(Long userId) {
        userService.delete(userId); // Changed from deleteUser to delete
    }

    public boolean validateAdminCredentials(String email, String password) {
        return email.equals("adminNG@gmail.com") && password.equals("PBO123");
    }

    public boolean isAdmin(String email) {
        User user = userRepository.findByEmail(email)
            .orElseThrow(() -> new ResourceNotFoundException("User not found"));
        return "ADMIN".equals(user.getRole());
    }
}