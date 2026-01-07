use x_win::{get_active_window, get_open_windows, XWinError, WindowInfo, get_window_icon};
use flutter_rust_bridge::frb;
use crate::frb_generated::StreamSink;
use std::sync::{Arc, Mutex};
use std::thread;
use std::time::Duration;
use std::collections::HashMap;
use std::sync::atomic::{AtomicU64, Ordering};

// Store running listeners with unique IDs
lazy_static::lazy_static! {
    static ref WINDOW_LISTENERS: Mutex<HashMap<u64, Arc<Mutex<bool>>>> = Mutex::new(HashMap::new());
    static ref NEXT_LISTENER_ID: AtomicU64 = AtomicU64::new(1);
}

#[derive(Clone, Debug)]
pub struct WindowDetails {
    pub id: u32,
    pub title: String,
    pub position: (i32, i32, i32, i32), // x, y, width, height
    pub is_full_screen: bool,
    pub process_name: String,
    pub process_path: String,
    pub process_id: u32,
    pub os: String,  // Add OS field to help with platform-specific handling
}

fn convert_window_info(window: &WindowInfo) -> WindowDetails {
    WindowDetails {
        id: window.id,
        title: window.title.clone(),
        position: (
            window.position.x,
            window.position.y,
            window.position.width,
            window.position.height,
        ),
        is_full_screen: window.position.is_full_screen,
        process_name: window.info.name.clone(),
        process_path: window.info.path.clone(),
        process_id: window.info.process_id,
        os: window.os.clone(), // x-win provides this field with platform info
    }
}

#[frb(sync)]
pub fn get_active_window_info() -> Result<WindowDetails, String> {
    match get_active_window() {
        Ok(window) => Ok(convert_window_info(&window)),
        Err(XWinError) => Err("Error occurred while getting active window".to_string()),
    }
}

#[frb(sync)]
pub fn get_open_windows_info() -> Result<Vec<WindowDetails>, String> {
    match get_open_windows() {
        Ok(windows) => {
            let details: Vec<WindowDetails> = windows.iter()
                .map(|window| convert_window_info(window))
                .collect();
            Ok(details)
        },
        Err(XWinError) => Err("Error occurred while getting open windows".to_string()),
    }
}

#[frb(sync)]
pub fn get_window_icon_data(window_id: u32) -> Result<String, String> {  // Changed from i32 to u32
    match get_active_window() {
        Ok(active_window) => {
            if active_window.id == window_id {
                return match get_window_icon(&active_window) {
                    Ok(icon_info) => Ok(icon_info.data),
                    Err(XWinError) => Err("Error occurred while getting window icon".to_string()),
                };
            }
            
            match get_open_windows() {
                Ok(windows) => {
                    for window in windows {
                        if window.id == window_id {
                            return match get_window_icon(&window) {
                                Ok(icon_info) => Ok(icon_info.data),
                                Err(XWinError) => Err("Error getting window icon".to_string()),
                            };
                        }
                    }
                    Err("Window not found".to_string())
                },
                Err(XWinError) => Err("Error occurred while getting open windows".to_string()),
            }
        },
        Err(XWinError) => Err("Error occurred while getting active window".to_string()),
    }
}

#[frb(sync)]
pub fn is_platform_supported() -> bool {
    // This function checks if the current platform is supported
    // x-win should handle most platforms, but this provides an explicit check
    cfg!(any(target_os = "windows", target_os = "macos", target_os = "linux"))
}

#[frb(sync)]
pub fn get_current_platform() -> String {
    if cfg!(target_os = "windows") {
        "windows".to_string()
    } else if cfg!(target_os = "macos") {
        "macos".to_string()
    } else if cfg!(target_os = "linux") {
        "linux".to_string()
    } else {
        "unknown".to_string()
    }
}

#[frb(sync)]
pub fn start_window_listener_stream(sink: StreamSink<WindowDetails>) -> u64 {
    let running = Arc::new(Mutex::new(true));
    let running_clone = Arc::clone(&running);
    
    // Generate a unique ID for this listener
    let listener_id = NEXT_LISTENER_ID.fetch_add(1, Ordering::SeqCst);
    
    // Store the control handle
    WINDOW_LISTENERS.lock().unwrap().insert(listener_id, running);
    
    thread::spawn(move || {
        let mut last_window_id: u32 = 0;
        
        // Use a different polling frequency based on platform
        let polling_interval = if cfg!(target_os = "windows") {
            Duration::from_millis(300) // Windows is generally faster
        } else if cfg!(target_os = "macos") {
            Duration::from_millis(500) // Default for macOS
        } else {
            Duration::from_millis(700) // Slower for Linux and others to reduce overhead
        };
        
        while *running_clone.lock().unwrap() {
            match get_active_window() {
                Ok(window) => {
                    if window.id != last_window_id {
                        let window_details = convert_window_info(&window);
                        last_window_id = window.id;
                        sink.add(window_details);
                    }
                },
                Err(_) => {
                    // Continue on error, just wait for next check
                    // If errors persist on specific platforms, we could add platform-specific error handling here
                }
            }
            thread::sleep(polling_interval);
        }
    });
    
    listener_id
}

// Legacy version - keep this for backward compatibility
#[frb(sync)]
pub fn start_window_listener(sink: StreamSink<WindowDetails>) -> u64 {
    start_window_listener_stream(sink)
}

#[frb(sync)]
pub fn stop_window_listener(listener_id: u64) -> bool {
    let mut listeners = WINDOW_LISTENERS.lock().unwrap();
    
    if let Some(running) = listeners.remove(&listener_id) {
        if let Ok(mut guard) = running.lock() {
            *guard = false;
        }
        true
    } else {
        false
    }
}
