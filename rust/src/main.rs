use std::env;
use std::fs;
use std::path::PathBuf;

fn main() -> Result<(), Box<dyn std::error::Error>> {
    let base = env::var("LOCALAPPDATA")
        .map(PathBuf::from)
        .unwrap_or_else(|_| PathBuf::from("."))
        .join("Zephyr");

    fs::create_dir_all(&base)?;

    let compiler_stub = b"ZEPHYR_COMPILER_STUB";
    fs::write(base.join("zephyr.exe"), compiler_stub)?;

    println!("Zephyr installed to {}", base.display());
    println!("Add {} to PATH.", base.display());
    Ok(())
}
