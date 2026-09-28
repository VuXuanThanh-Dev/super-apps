// objective: 4.1
// Exception tự định nghĩa (custom): checked extends Exception, unchecked extends RuntimeException; gói cause.
public class Ex06_CustomException {
    static class InsufficientFundsException extends Exception {      // checked
        private final long missing;
        InsufficientFundsException(String msg, long missing) { super(msg); this.missing = missing; }
        long getMissing() { return missing; }
    }

    static class AccountLockedException extends RuntimeException {  // unchecked
        AccountLockedException(String msg, Throwable cause) { super(msg, cause); }
    }

    static long balance = 100;

    static void withdraw(long amount) throws InsufficientFundsException {
        if (amount > balance) throw new InsufficientFundsException("need more money", amount - balance);
        balance -= amount;
    }

    public static void main(String[] args) {
        try {
            withdraw(30);
            withdraw(500);
        } catch (InsufficientFundsException e) {
            System.out.println(e.getMessage() + ", missing " + e.getMissing() + ", balance " + balance);
            try {
                throw new AccountLockedException("locked", e);
            } catch (AccountLockedException ex) {
                System.out.println(ex + " / cause: " + ex.getCause().getClass().getSimpleName());
            }
        }
    }
}
