String usernameWithEmoji(String username) {
  const numToEmoji = {
    "0": "0️⃣",
    "1": "1️⃣",
    "2": "2️⃣",
    "3": "3️⃣",
    "4": "4️⃣",
    "5": "5️⃣",
    "6": "6️⃣",
    "7": "7️⃣",
    "8": "8️⃣",
    "9": "9️⃣",
  };

  if (username.isEmpty) return username;

  String lastChar = username[username.length - 1];

  if (numToEmoji.containsKey(lastChar)) {
    return username.substring(0, username.length - 1) + numToEmoji[lastChar]!;
  }
  return username;
}
void main() {
  print(usernameWithEmoji("22bce9292")); // 22bce9292️⃣
  print(usernameWithEmoji("22bce9295")); // 22bce9295️⃣
}