import java.util.Scanner;

public class sample {
    // iterative factorial for non-negative integers
    public static long factorial(int n) {
        if (n < 0) throw new IllegalArgumentException("Negative number");
        long result = 1;
        for (int i = 2; i <= n; i++) result *= i;
        return result;
    }

    // recursive version (optional)
    public static long factorialRecursive(int n) {
        if (n < 0) throw new IllegalArgumentException("Negative number");
        return (n <= 1) ? 1 : n * factorialRecursive(n - 1);
    }

    public static void main(String[] args) {
        Scanner sc = new Scanner(System.in);
        System.out.print("Enter a non-negative integer: ");
        if (!sc.hasNextInt()) {
            System.out.println("Invalid input");
            sc.close();
            return;
        }
        int n = sc.nextInt();
        sc.close();
        if (n < 0) {
            System.out.println("Factorial is not defined for negative numbers.");
            return;
        }
        System.out.println("Iterative: " + factorial(n));
        System.out.println("Recursive: " + factorialRecursive(n));
    }
}
