#include <linux/init.h>
#include <linux/module.h>

#include <linux/kernel.h>
#include <linux/fs.h>
#include <linux/device.h>
#include <linux/uaccess.h>

#define DEVICE_NAME "flag"
#define CLASS_NAME "flag"

MODULE_AUTHOR("vilex");
MODULE_DESCRIPTION("Flag devices");
MODULE_LICENSE("GPL");

int major;
char flag[24] = "flag{Here_is_your_flag}\0";
static struct class*  my_class  = NULL;
static struct device* my_device = NULL;

static ssize_t 
flag_read(struct file *filp, char __user *buffer, size_t len, loff_t *off) {
    if(len > 23)
    {
        printk(KERN_ALERT "Too much");
        return -EFAULT;
    }
    printk(KERN_ALERT "reading...");
    int ret = copy_to_user(buffer, flag, len);
    if(ret == len)
    {
        printk(KERN_ALERT "Error");
        return -EFAULT;
    }
    printk(KERN_ALERT "sucess");
    return len-ret;
}

static ssize_t 
flag_write(struct file *filp, const char __user *buffer, size_t count, loff_t *pos) {
    if(count > 23)
    {
        printk(KERN_ALERT "Too much");
        return -EFAULT;
    }
    printk(KERN_ALERT "writing...");
    int ret = copy_from_user(flag, buffer, count);
    if(ret == count)
    {
        printk(KERN_ALERT "Error");
        return -EFAULT;
    }
    printk(KERN_ALERT "sucess");
    return count-ret;
}

static struct file_operations fops = {
    .read = flag_read, 
    .write = flag_write
};

static int __init flag_init(void) {
    major = register_chrdev(0, DEVICE_NAME, &fops);

    if ( major < 0 )
        printk(KERN_ALERT "[flag] Error assigning Major Number!");
    
    my_class = class_create(CLASS_NAME);
    if (IS_ERR(my_class)) {
        unregister_chrdev(major, DEVICE_NAME);
        printk(KERN_ALERT "[flag] Failed to register device class\n");
    }

    my_device = device_create(my_class, NULL, MKDEV(major, 0), NULL, DEVICE_NAME);
    if (IS_ERR(my_device)) {
        class_destroy(my_class);
        unregister_chrdev(major, DEVICE_NAME);
        printk(KERN_ALERT "[flag] Failed to create the device\n");
    }

    return 0;
}

static void __exit flag_exit(void) {
    device_destroy(my_class, MKDEV(major, 0));              
    class_unregister(my_class);              
    class_destroy(my_class);                               
    unregister_chrdev(major, DEVICE_NAME);              
    printk(KERN_INFO "[flag] Closing!\n");
}

module_init(flag_init);
module_exit(flag_exit);
