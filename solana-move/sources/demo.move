/// Module: demo
module demo::demo {
  entry fun main(val: u8): u8 {
    val + 1
  }

  #[test]
  fun test() { }
}
